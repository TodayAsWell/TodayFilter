import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    var sceneView: ARSCNView!
    var faceNode: SCNNode!
    var material = SCNMaterial()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a new ARSCNView
        sceneView = ARSCNView()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        view.addSubview(sceneView)

        // Add constraints to ARSCNView
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene

        // Create a material for the face node
        material.diffuse.contents = UIColor.red // 초기 색상 설정 (임시값)

        // Create a face geometry
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial = material

        // Add the face node to the scene
        sceneView.scene.rootNode.addChildNode(faceNode)

        // Create segmented control
        let segmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"])
        segmentedControl.addTarget(self, action: #selector(changeFilterColor(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        // Add constraints to segmented control
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])

        // Configure AR session
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    // Handle AR session error
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    @objc func changeFilterColor(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            material.diffuse.contents = UIColor.red
        case 1:
            material.diffuse.contents = UIColor.green
        case 2:
            material.diffuse.contents = UIColor.blue
        default:
            break
        }
        faceNode.geometry?.firstMaterial = material
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }
}
