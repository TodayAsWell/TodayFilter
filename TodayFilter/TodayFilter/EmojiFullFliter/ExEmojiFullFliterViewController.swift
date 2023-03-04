//
//  ViewController.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/04.
//

import UIKit
import ARKit

class ExEmojiFullFliterViewController: UIViewController {
    
    let sceneView = ARSCNView()
    let fullFaceOptions = ["😀", "😂", "😍", "😜", "😎", "🤔", "😷", "😱", "👽"]
    let features = ["fullFace"]
    let featureIndices = [[0]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = self
        sceneView.frame = view.frame
        view.addSubview(sceneView)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("ARKit is not supported on this device")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? EmojiFullNode1
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
            
            let fullFaceValue = anchor.blendShapes[.mouthFunnel]?.floatValue ?? 0.0
            let fullFaceIndex = Int(fullFaceValue * Float(fullFaceOptions.count - 1))
            child?.options = [fullFaceOptions[fullFaceIndex]]
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: nil)
        if let result = results.first,
           let node = result.node as? EmojiFullNode1 {
            node.next()
        }
    }
}

extension ExEmojiFullFliterViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let device = sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        node.geometry?.firstMaterial?.transparency = 0.2
        let fullFaceNode = EmojiFullNode1(with: fullFaceOptions)
        fullFaceNode.name = "fullFace"
        node.addChildNode(fullFaceNode)
        
        updateFeatures(for: node, using: faceAnchor)
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
}

class EmojiFullNode1: SCNNode {
    
    var options: [String]
    var index = 0
    
    init(with options: [String], width: CGFloat = 0.1, height: CGFloat = 0.1) {
        self.options = options
        
        super.init()
        
        // Create a plane geometry and set its material
        let plane = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = options[index]
        plane.materials = [material]
        geometry = plane
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(for vertices: [SIMD3<Float>]) {
        guard let average = vertices.average() else { return }
        position = SCNVector3(average)
    }
    
    func next() {
        index = (index + 1) % options.count
        geometry?.materials.first?.diffuse.contents = options[index]
    }
}
