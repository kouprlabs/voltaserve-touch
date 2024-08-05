import GLTFKit2
import SceneKit
import SwiftUI

struct V3DView: UIViewRepresentable {
    @ObservedObject var document: V3DDocument

    class Coordinator {
        var document: V3DDocument
        var asset: GLTFAsset?
        var sceneView: SCNView
        var animations = [GLTFSCNAnimation]()
        let cameraNode = SCNNode()

        init(sceneView: SCNView, document: V3DDocument) {
            self.sceneView = sceneView
            self.document = document

            let camera = SCNCamera()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 2)
        }

        func loadAsset() {
            document.loadAsset { [self] asset in
                if let asset {
                    self.asset = asset
                    setupScene()
                }
            }
        }

        private func setupScene() {
            guard let asset else { return }
            let source = GLTFSCNSceneSource(asset: asset)
            if let scene = source.defaultScene {
                sceneView.scene = scene
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
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneView: SCNView(), document: document)
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = context.coordinator.sceneView
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true

        context.coordinator.loadAsset()

        return sceneView
    }

    func updateUIView(_: SCNView, context _: Context) {}
}
