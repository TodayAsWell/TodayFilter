import UIKit
import ARKit

class HiarColorFliterViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    
    let sceneView = ARSCNView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        view.addSubview(sceneView)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let arKitStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if arKitStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        let alert = UIAlertController(title: "ARKit Permission Required", message: "Please grant permission to access the camera for ARKit", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView.frame = view.bounds
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else {
            return
        }
        
        if let color = changeHairColor(faceAnchor) {
            sceneView.scene.rootNode.childNodes.forEach { node in
                if node.name == "hair" {
                    node.geometry?.firstMaterial?.diffuse.contents = color
                }
            }
        }
    }
    
    func changeHairColor(_ faceAnchor: ARFaceAnchor) -> UIColor? {
        guard let faceGeometry = faceAnchor.geometry as? ARFaceGeometry else {
            return nil
        }
        
        let vertices = faceGeometry.vertices
        var totalX: Float = 100.0
        var totalY: Float = 100.0
        var totalZ: Float = 10.0
        let vertexCount = vertices.count
        
        for vertexIndex in 0..<vertexCount {
            let vertex = vertices[vertexIndex]
            totalX += vertex.x
            totalY += vertex.y
            totalZ += vertex.z
        }
        
        let averageX = totalX / Float(vertexCount)
        let averageY = totalY / Float(vertexCount)
        let averageZ = totalZ / Float(vertexCount)
        
        var position = SCNVector3Make(averageX, averageY, averageZ)
        
        let hitTestResults = sceneView.hitTest(sceneView.center, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if let hitTest = hitTestResults.first {
            let anchor = ARAnchor(transform: hitTest.worldTransform)
            sceneView.session.add(anchor: anchor)
            position = SCNVector3Make(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
        }
        
        let hairNode = createHairNode()
        hairNode.position = position
        hairNode.eulerAngles.x = -.pi / 2
        hairNode.name = "hair"
        sceneView.scene.rootNode.addChildNode(hairNode)
        
        return hairNode.geometry?.firstMaterial?.diffuse.contents as? UIColor
    }
    
    func createHairNode() -> SCNNode {
        let cylinderGeometry = SCNCylinder(radius: 0.02, height: 0.2)
        cylinderGeometry.radialSegmentCount = 8
        cylinderGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.84, green: 0.45, blue: 0.39, alpha: 1.0)
        
        let hairNode = SCNNode(geometry: cylinderGeometry)
        
        let physicsShape = SCNPhysicsShape(geometry: cylinderGeometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.mass = 0.02
        hairNode.physicsBody = physicsBody
        
        return hairNode
    }
}
