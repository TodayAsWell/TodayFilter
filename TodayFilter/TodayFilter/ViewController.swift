//
//  ViewController.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/03.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // ARSCNView 인스턴스 생성
    let arView = ARSCNView()

    // ARSession 인스턴스 생성
    let arSession = ARSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ARSCNView 설정
        self.arView.delegate = self
        self.arView.session = self.arSession

        // ARSCNView를 현재 뷰에 추가
        self.view.addSubview(self.arView)
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.arView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.arView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.arView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // ARSession 구성
        let configuration = ARWorldTrackingConfiguration()
        self.arSession.run(configuration)
    }

    // ARSCNViewDelegate 메서드 구현
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // ARAnchor에 대한 SCNNode 생성
        let node = SCNNode()

        // 머리 모델 로드
        guard let head = SCNScene(named: "art.scnassets/head/head.scn")?.rootNode else {
            fatalError("Failed to load head model.")
        }
        node.addChildNode(head)

        // 머리 모델 위치 및 크기 설정
        head.scale = SCNVector3(0.5, 0.5, 0.5)
        head.position = SCNVector3(0, 0, -1)

        // SCNNode 반환
        return node
    }

    // ARSCNViewDelegate 메서드 구현
    func session(_ session: ARSession, didFailWithError error: Error) {
        // ARSession 오류 처리
        print("ARSession error: \(error.localizedDescription)")
    }

    // ARSCNViewDelegate 메서드 구현
    func sessionWasInterrupted(_ session: ARSession) {
        // ARSession 일시 중지 처리
        print("ARSession was interrupted.")
    }

    // ARSCNViewDelegate 메서드 구현
    func sessionInterruptionEnded(_ session: ARSession) {
        // ARSession 일시 중지 해제 처리
        print("ARSession interruption ended.")
    }

    // 사용자가 머리를 터치하면 머리 색을 빨간색으로 변경하는 메서드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        print("터치")

        let touchLocation = touch.location(in: self.arView)
        let raycastQuery = self.arView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal)

        guard let hitTestResult = self.arView.session.raycast(raycastQuery!).first else { return }

        let anchor = hitTestResult.anchor!
        let node = self.arView.node(for: anchor)

        node?.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
}
