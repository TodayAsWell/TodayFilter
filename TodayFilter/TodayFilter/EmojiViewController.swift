//
//  EmojiViewController.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/03.
//

import UIKit
import Then
import SnapKit
import ARKit

class EmojiViewController: UIViewController {
    private var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
}


