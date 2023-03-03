//
//  ViewController.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/03.

//
import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController {
    var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARSCNView 설정
        sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        
        // constraints 추가
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        // ARSCNView 설정
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        // Reality Composer로 만든 AR 콘텐츠를 가져옴
        let rcScene = try! Exp
        
        // AR 콘텐츠를 SCNNode로 변환
        let scene = rcScene.scene
        
        // 콘텐츠를 sceneView에 추가
        sceneView.scene = scene
    }
}
