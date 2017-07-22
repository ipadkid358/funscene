//
//  GameViewController.swift
//  funscene
//
//  Created by ipad_kid on 7/15/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    // create a new scene
    private let scene: SCNScene = SCNScene(named: "main.scn")!
    
    @IBOutlet public weak var scnView: SCNView!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let scnStats: String = "scnStats"
    private let camLock: String = "camLock"
    private let upForce: String = "upForce"
    private let gravityValue: String = "gravityValue"
    private let darkMode: String = "darkMode"
    private let skyColor: String = "skyColor"
    private let floorColor: String = "floorColor"
    private let cubeColor: String = "cubeColor"
    
    
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
        
        guard let floorNode: SCNNode = scene.rootNode.childNode(withName: "floor", recursively: true) else { return }
        let geoFloor: SCNFloor? = floorNode.geometry as? SCNFloor
        guard let floor = geoFloor, let floorMaterial = floor.firstMaterial else { return }
        floorMaterial.diffuse.contents = UIColor(hue: CGFloat(userDefaults.float(forKey: "\(darkPrefix)\(floorColor)")), saturation: 1, brightness: brightness, alpha: 1)
        
        guard let boxNodes: SCNNode = scene.rootNode.childNode(withName: "boxes", recursively: true) else { return }
        let boxes: [SCNNode] = boxNodes.childNodes
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
        
        // create and add a light to the scene
        let lightNode: SCNNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode: SCNNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // set the scene to the view
        scnView.scene = scene
        setSceneSettings()
        
        // add a tap gesture recognizer
        let tapGesture: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p: CGPoint = gestureRecognize.location(in: scnView)
        let hitResults: Array = scnView.hitTest(p)
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: SCNHitTestResult = hitResults[0]
            guard let hitPhyNode: SCNPhysicsBody = result.node.physicsBody else { return }
            hitPhyNode.applyForce(SCNVector3(x: 0, y: userDefaults.float(forKey: upForce), z: 0), asImpulse: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
