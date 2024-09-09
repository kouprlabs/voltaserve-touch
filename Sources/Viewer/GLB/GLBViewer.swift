import GLTFKit2
import SceneKit
import SwiftUI
import VoltaserveCore

struct GLBViewer: View {
    @EnvironmentObject private var glbStore: GLBStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isGLB() {
            Viewer3DRenderer(file)
        }
    }
}

struct Viewer3DRenderer: UIViewRepresentable {
    @EnvironmentObject private var glbStore: GLBStore
    @State private var isLoading = true
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)

        let sceneView = context.coordinator.sceneView
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .white

        sceneView.isHidden = true
        containerView.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: containerView.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        containerView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        context.coordinator.spinner = spinner
        context.coordinator.loadAsset(file.id)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        uiView.subviews.first { $0 is SCNView }?.isHidden = isLoading
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneView: SCNView(), store: glbStore, isLoading: $isLoading)
    }

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var glbStore: GLBStore
        var asset: GLTFAsset?
        var sceneView: SCNView
        var animations = [GLTFSCNAnimation]()
        let cameraNode = SCNNode()
        var spinner: UIActivityIndicatorView?
        @Binding var isLoading: Bool

        init(sceneView: SCNView, store: GLBStore, isLoading: Binding<Bool>) {
            self.sceneView = sceneView
            glbStore = store
            _isLoading = isLoading

            let camera = SCNCamera()
            camera.usesOrthographicProjection = false
            camera.zNear = 0.1
            camera.zFar = 100
            cameraNode.camera = camera

            super.init()

            sceneView.delegate = self

            // Initially pause the scene view
            sceneView.isPlaying = false
        }

        func loadAsset(_ id: String) {
            glbStore.loadAsset(id) { [self] asset, _ in
                if let asset {
                    self.asset = asset
                    setupScene()
                    isLoading = false
                }
            }
        }

        private func setupScene() {
            guard let asset else { return }
            let source = GLTFSCNSceneSource(asset: asset)
            if let scene = source.defaultScene {
                sceneView.scene = scene
                sceneView.pointOfView = cameraNode

                // Remove the spinner once the asset is loaded
                DispatchQueue.main.async {
                    self.spinner?.removeFromSuperview()
                }

                // Adjust the camera to fit the object using SceneKit's built-in API
                adjustCameraToFitObject()
            }
            animations = source.animations
            if let defaultAnimation = animations.first {
                defaultAnimation.animationPlayer.animation.usesSceneTimeBase = false
                defaultAnimation.animationPlayer.animation.repeatCount = .greatestFiniteMagnitude

                sceneView.scene?.rootNode.addAnimationPlayer(defaultAnimation.animationPlayer, forKey: nil)

                defaultAnimation.animationPlayer.play()
            }
            sceneView.scene?.rootNode.addChildNode(cameraNode)
        }

        private func adjustCameraToFitObject() {
            guard let scene = sceneView.scene else { return }

            // Calculate the bounding box of the entire scene, including transformations
            let (minVec, maxVec) = scene.rootNode.boundingBoxRelativeToCurrentObject()
            let center = SCNVector3(
                (minVec.x + maxVec.x) / 2,
                (minVec.y + maxVec.y) / 2,
                (minVec.z + maxVec.z) / 2
            )
            let extents = SCNVector3(
                maxVec.x - minVec.x,
                maxVec.y - minVec.y,
                maxVec.z - minVec.z
            )
            let maxExtent = max(extents.x, extents.y, extents.z)

            // Scale the model if it's too small
            let scaleFactor: Float = maxExtent < 0.5 ? 1.0 / maxExtent : 1.0
            scene.rootNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)

            // Assuming a comfortable distance factor
            let adjustedExtent = maxExtent * scaleFactor
            let distance = adjustedExtent * 2.0

            cameraNode.position = SCNVector3(center.x, center.y + extents.y / 2, center.z + distance)

            // Update the camera's look-at point on the main thread to ensure synchronization
            DispatchQueue.main.async {
                self.cameraNode.look(at: center)

                // Only start playing the view after the camera is adjusted and asset is loaded
                self.sceneView.isPlaying = true
            }
        }
    }
}

extension SCNNode {
    // Helper function to calculate the bounding box considering all child nodes and transformations
    func boundingBoxRelativeToCurrentObject() -> (SCNVector3, SCNVector3) {
        var minVec: SCNVector3 = SCNVector3Zero
        var maxVec: SCNVector3 = SCNVector3Zero
        var first = true

        enumerateChildNodes { node, _ in
            let (nodeMin, nodeMax) = node.boundingBox

            // Apply node transformation to the bounding box
            let transformedMin = node.convertPosition(nodeMin, to: self)
            let transformedMax = node.convertPosition(nodeMax, to: self)

            if first {
                minVec = transformedMin
                maxVec = transformedMax
                first = false
            } else {
                minVec.x = Swift.min(minVec.x, transformedMin.x)
                minVec.y = Swift.min(minVec.y, transformedMin.y)
                minVec.z = Swift.min(minVec.z, transformedMin.z)
                maxVec.x = Swift.max(maxVec.x, transformedMax.x)
                maxVec.y = Swift.max(maxVec.y, transformedMax.y)
                maxVec.z = Swift.max(maxVec.z, transformedMax.z)
            }
        }

        return (minVec, maxVec)
    }
}
