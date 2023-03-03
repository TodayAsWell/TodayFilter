//
//  FaceFliterViewController.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/03.
//

import UIKit
import ARKit

private let planeWidth: CGFloat = 0.13
private let planeHeight: CGFloat = 0.06
private let nodeYPosition: Float = 0.022
private let minPositionDistance: Float = 0.0025
private let minScaling: CGFloat = 0.025
private let cellIdentifier = "GlassesCollectionViewCell"
private let glassesCount = 4
private let animationDuration: TimeInterval = 0.25
private let cornerRadius: CGFloat = 10

class ViewController: UIViewController {
    
    private let sceneView = ARSCNView(frame: .zero)
    private let glassesView = UIView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let calibrationView = UIView()
    private let calibrationTransparentView = UIView()
    private let collectionBottomConstraint: NSLayoutConstraint
    private let calibrationBottomConstraint: NSLayoutConstraint
    private let collectionButton = UIButton()
    private let calibrationButton = UIButton()
    private let alertLabel = UILabel()
    
    private let glassesPlane = SCNPlane(width: planeWidth, height: planeHeight)
    private let glassesNode = SCNNode()
    
    private var scaling: CGFloat = 1
    
    private var isCollecionOpened = false {
        didSet {
            updateCollectionPosition()
        }
    }
    private var isCalibrationOpened = false {
        didSet {
            updateCalibrationPosition()
        }
    }
    
    init() {
        collectionBottomConstraint = NSLayoutConstraint(item: glassesView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -glassesView.bounds.size.height)
        calibrationBottomConstraint = NSLayoutConstraint(item: calibrationView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -calibrationView.bounds.size.height)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            alertLabel.text = "Face tracking is not supported on this device"
            return
        }
        
        setupSceneView()
        setupGlassesView()
        setupCollectionView()
        setupCalibrationView()
        
        view.addSubview(sceneView)
        view.addSubview(glassesView)
        glassesView.addSubview(collectionView)
        view.addSubview(calibrationView)
        calibrationView.addSubview(calibrationTransparentView)
        calibrationView.addSubview(calibrationButton)
        glassesView.addSubview(collectionButton)
        view.addSubview(alertLabel)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            glassesView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            glassesView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            collectionBottomConstraint,
            glassesView.heightAnchor.constraint(equalToConstant: 100),
            
            collectionView.topAnchor.constraint(equalTo: glassesView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: glassesView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: glassesView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: glassesView.rightAnchor),
            
            collectionButton.topAnchor.constraint(equalTo: glassesView.topAnchor, constant: -16),
            collectionButton.leftAnchor.constraint(equalTo: glassesView.leftAnchor),
            collectionButton.widthAnchor.constraint(equalToConstant: 50),
            collectionButton.heightAnchor.constraint(equalToConstant: 50),
            calibrationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            calibrationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            calibrationBottomConstraint,
            calibrationView.heightAnchor.constraint(equalToConstant: 120),
            
            calibrationTransparentView.topAnchor.constraint(equalTo: calibrationView.topAnchor),
            calibrationTransparentView.leftAnchor.constraint(equalTo: calibrationView.leftAnchor),
            calibrationTransparentView.rightAnchor.constraint(equalTo: calibrationView.rightAnchor),
            calibrationTransparentView.bottomAnchor.constraint(equalTo: calibrationView.bottomAnchor),
            
            calibrationButton.bottomAnchor.constraint(equalTo: calibrationView.bottomAnchor, constant: -16),
            calibrationButton.leftAnchor.constraint(equalTo: calibrationView.leftAnchor),
            calibrationButton.rightAnchor.constraint(equalTo: calibrationView.rightAnchor),
            calibrationButton.heightAnchor.constraint(equalToConstant: 50),
            
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        calibrationButton.addTarget(self, action: #selector(calibrationButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    private func setupSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
        sceneView.showsStatistics = true
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupGlassesView() {
        glassesView.translatesAutoresizingMaskIntoConstraints = false
        glassesView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        glassesView.layer.cornerRadius = cornerRadius
        glassesView.layer.masksToBounds = true
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(GlassesCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
        }
    }
    
    private func setupCalibrationView() {
        calibrationView.translatesAutoresizingMaskIntoConstraints = false
        calibrationView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        calibrationView.layer.cornerRadius = cornerRadius
        calibrationView.layer.masksToBounds = true
        
        calibrationTransparentView.translatesAutoresizingMaskIntoConstraints = false
        calibrationTransparentView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        calibrationButton.translatesAutoresizingMaskIntoConstraints = false
        calibrationButton.setTitle("Calibrate", for: .normal)
        calibrationButton.setTitleColor(.white, for: .normal)
        calibrationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        calibrationButton.backgroundColor = UIColor(red: 45/255, green: 136/255, blue: 255/255, alpha: 1)
        calibrationButton.layer.cornerRadius = cornerRadius
        calibrationButton.layer.masksToBounds = true
    }
    
    private func updateCollectionPosition() {
        let bottomConstant: CGFloat = isCollecionOpened ? 0 : -glassesView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionBottomConstraint.constant = bottomConstant
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition() {
        let bottomConstant: CGFloat = isCalibrationOpened ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.calibrationBottomConstraint.constant = bottomConstant
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func collectionButtonTapped() {
        isCollecionOpened.toggle()
    }
    
    @objc private func calibrationButtonTapped() {
        isCalibrationOpened.toggle()
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard !isCollecionOpened else { return }
        guard !isCalibrationOpened else { return }
        
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [.boundingBoxOnly : true])
        if let result = hitResults.first {
            if result.node == glassesNode || result.node.parent == glassesNode {
                scaling = CGFloat(glassesNode.scale.x)
                let distance = simd_distance(sceneView.pointOfView!.simdTransform.columns.3, result.node.simdTransform.columns.3)
                calibrationTransparentView.alpha = 1 - CGFloat(distance / minPositionDistance)
                calibrationButton.isEnabled = distance < minPositionDistance
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        let contentNode = SCNNode()
        
        // Initialize glassesNode
        let glassesNode = SCNNode()
        glassesNode.geometry = glassesPlane
        glassesNode.geometry?.firstMaterial?.isDoubleSided = true
        glassesNode.position = SCNVector3(0, nodeYPosition, -0.06)
        glassesNode.eulerAngles.x = -.pi / 2
        
        let faceGeometry = ARSCNFaceGeometry(device: renderer.device!)
        contentNode.geometry = faceGeometry
        contentNode.addChildNode(glassesNode) // Add glassesNode to contentNode
        
        return contentNode
    }
}
