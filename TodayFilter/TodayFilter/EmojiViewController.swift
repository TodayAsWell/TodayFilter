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
    
    let nose = ["✨"]
    let eye = ["🖤"]
    let mouth = ["🍀"]
    let hat = ["⚡️"]
    let features = ["nose", "leftEye", "rightEye", "mouth", "hat"]
    let featureIndices = [[9], [1064], [42], [24, 25], [20]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
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
}


