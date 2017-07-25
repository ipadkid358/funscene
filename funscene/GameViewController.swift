//
//  GameViewController.swift
//  funscene
//
//  Created by ipad_kid on 7/15/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    private let scene: SCNScene = SCNScene(named: "main.scn")!
    
    @IBOutlet public weak var scnView: SCNView!
    @IBOutlet weak var cubeHeight: UILabel!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let scnStats: String = "scnStats"
    private let camLock: String = "camLock"
    private let upForce: String = "upForce"
    private let gravityValue: String = "gravityValue"
    private let darkMode: String = "darkMode"
    private let skyColor: String = "skyColor"
    private let floorColor: String = "floorColor"
    private let cubeColor: String = "cubeColor"
    var boxes: [SCNNode] = []
    var geoFloor: SCNFloor? = nil
    
    func setSceneSettings() {
        let darkPrefix: String
        let brightness: CGFloat
        if userDefaults.bool(forKey: darkMode) {
            darkPrefix = "dark"
            brightness = 0.6
        } else {
            darkPrefix = ""
            brightness = 0.9
        }
        
        scene.physicsWorld.gravity.y = userDefaults.float(forKey: gravityValue)
        scnView.allowsCameraControl = !userDefaults.bool(forKey: camLock)
        scnView.showsStatistics = userDefaults.bool(forKey: scnStats)
        
        scnView.backgroundColor = UIColor(hue: CGFloat(userDefaults.float(forKey: "\(darkPrefix)\(skyColor)")), saturation: 1, brightness: brightness, alpha: 1)
        
        guard let floor = geoFloor, let floorMaterial = floor.firstMaterial else { return }
        floorMaterial.diffuse.contents = UIColor(hue: CGFloat(userDefaults.float(forKey: "\(darkPrefix)\(floorColor)")), saturation: 1, brightness: brightness, alpha: 1)
        
        for box: SCNNode in boxes {
            let geoBox: SCNBox? = box.geometry as? SCNBox
            guard let boxNode: SCNBox = geoBox, let boxMaterial = boxNode.firstMaterial else { return }
            boxMaterial.diffuse.contents = UIColor(hue: CGFloat(userDefaults.float(forKey: "\(darkPrefix)\(cubeColor)")), saturation: 1, brightness: brightness, alpha: 1)
        }
    }
    
    func setDefaultsIfNone () {
        guard let appBundle: String = Bundle.main.bundleIdentifier else { return }
        let appLibPath: [String] = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        if FileManager.default.fileExists(atPath: "\(appLibPath[0])/Preferences/\(appBundle).plist") {
            return
        } else {
            userDefaults.set(5, forKey: upForce)
            userDefaults.set(-10, forKey: gravityValue)
            userDefaults.set(0.605, forKey: skyColor)
            userDefaults.set(0.075, forKey: floorColor)
            userDefaults.set(0.25, forKey: cubeColor)
            userDefaults.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the UserDefaults file doesn't exist, set values to values
        setDefaultsIfNone()
        
        // set the scene to the view
        scnView.scene = scene
        guard let floorNode: SCNNode = scene.rootNode.childNode(withName: "floor", recursively: true) else { return }
        geoFloor = floorNode.geometry as? SCNFloor
        
        guard let boxNodes: SCNNode = scene.rootNode.childNode(withName: "boxes", recursively: true) else { return }
        boxes = boxNodes.childNodes
        setSceneSettings()
        
        cubeHeight.layer.cornerRadius = 5
        
        // add a tap gesture recognizer
        let tapGesture: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        scnView.delegate = self
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p: CGPoint = gestureRecognize.location(in: scnView)
        let hitResults: Array = scnView.hitTest(p)
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            let result: SCNHitTestResult = hitResults[0]
            guard let hitPhyNode: SCNPhysicsBody = result.node.physicsBody else { return }
            hitPhyNode.applyForce(SCNVector3(x: 0, y: userDefaults.float(forKey: upForce), z: 0), asImpulse: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func updateHeightLabel() {
        var highest: Float = 0
        for box: SCNNode in boxes {
            highest = max(highest, box.presentation.position.y)
        }
        cubeHeight.text = String(Int(round(highest)))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.updateHeightLabel()
        }
    }
}
