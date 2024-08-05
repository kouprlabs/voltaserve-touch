import GLTFKit2
import SceneKit
import SwiftUI

// Helper function to calculate the bounding box considering all child nodes and transformations
extension SCNNode {
    func boundingBoxRelativeToCurrentObject() -> (SCNVector3, SCNVector3) {
        var minVec: SCNVector3 = SCNVector3Zero
        var maxVec: SCNVector3 = SCNVector3Zero
        var first = true

        enumerateChildNodes { node, _ in
            let (nodeMin, nodeMax) = node.boundingBox
            var localMin = nodeMin
            var localMax = nodeMax

            // Apply node transformation to the bounding box
            let transformedMin = node.convertPosition(localMin, to: self)
            let transformedMax = node.convertPosition(localMax, to: self)

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

struct V3DView: UIViewRepresentable {
    @ObservedObject var document: V3DDocument

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var document: V3DDocument
        var asset: GLTFAsset?
        var sceneView: SCNView
        var animations = [GLTFSCNAnimation]()
        let cameraNode = SCNNode()

        init(sceneView: SCNView, document: V3DDocument) {
            self.sceneView = sceneView
            self.document = document

            let camera = SCNCamera()
            camera.usesOrthographicProjection = false
            camera.zNear = 0.1
            camera.zFar = 100
            cameraNode.camera = camera
            super.init()
            sceneView.delegate = self
            sceneView.isPlaying = false // Initially pause the scene view
        }

        func loadAsset() {
            print("Loading asset...")
            document.loadAsset { [self] asset in
                if let asset {
                    print("Asset loaded successfully.")
                    self.asset = asset
                    setupScene()
                } else {
                    print("Failed to load asset.")
                }
            }
        }

        private func setupScene() {
            guard let asset else {
                print("No asset to set up scene.")
                return
            }
            let source = GLTFSCNSceneSource(asset: asset)
            if let scene = source.defaultScene {
                print("Default scene loaded.")
                sceneView.scene = scene
                sceneView.pointOfView = cameraNode

                // Adjust the camera to fit the object using SceneKit's built-in API
                adjustCameraToFitObject()
            } else {
                print("Failed to load default scene.")
            }
            animations = source.animations
            if let defaultAnimation = animations.first {
                print("Default animation found.")
                defaultAnimation.animationPlayer.animation.usesSceneTimeBase = false
                defaultAnimation.animationPlayer.animation.repeatCount = .greatestFiniteMagnitude

                sceneView.scene?.rootNode.addAnimationPlayer(defaultAnimation.animationPlayer, forKey: nil)

                defaultAnimation.animationPlayer.play()
            } else {
                print("No default animation found.")
            }
            sceneView.scene?.rootNode.addChildNode(cameraNode)
        }

        private func adjustCameraToFitObject() {
            guard let scene = sceneView.scene else {
                print("No scene to adjust camera for.")
                return
            }

            print("Adjusting camera to fit object...")
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

            print("Center: \(center), Extents: \(extents), Max extent: \(maxExtent)")

            // Scale the model if it's too small
            let scaleFactor: Float = maxExtent < 0.5 ? 1.0 / maxExtent : 1.0
            scene.rootNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
            print("Applied scale factor: \(scaleFactor)")

            // Assuming a comfortable distance factor
            let adjustedExtent = maxExtent * scaleFactor
            let distance = adjustedExtent * 2.0

            cameraNode.position = SCNVector3(center.x, center.y + extents.y / 2, center.z + distance)

            // Update the camera's look-at point on the main thread to ensure synchronization
            DispatchQueue.main.async {
                self.cameraNode.look(at: center)
                print("Camera positioned at: \(self.cameraNode.position)")

                // Only start playing the view after the camera is adjusted and asset is loaded
                self.sceneView.isPlaying = true
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneView: SCNView(), document: document)
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = context.coordinator.sceneView
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .white // Set the background color to white

        context.coordinator.loadAsset()

        return sceneView
    }

    func updateUIView(_: SCNView, context _: Context) {}
}
