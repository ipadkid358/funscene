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
    private let firstTime: String = "firstTime"
    

    func setSceneSettings() {
        scene.physicsWorld.gravity.y = userDefaults.float(forKey: gravityValue)
        scnView.allowsCameraControl = !userDefaults.bool(forKey: camLock)
        scnView.showsStatistics = userDefaults.bool(forKey: scnStats)
        scnView.backgroundColor = userDefaults.bool(forKey: darkMode) ? .darkGray : .white
        let floorWhite: CGFloat = userDefaults.bool(forKey: darkMode) ? 0.2 : 0.9
        
        guard let floorNode: SCNNode = scene.rootNode.childNode(withName: "floor", recursively: true) else { return }
        let geoFloor: SCNFloor? = floorNode.geometry as? SCNFloor
        guard let floor = geoFloor else { return }
        guard let floorMaterial = floor.firstMaterial else { return }
        floorMaterial.diffuse.contents = UIColor(white: floorWhite, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !userDefaults.bool(forKey: firstTime) {
            userDefaults.set(false, forKey: scnStats)
            userDefaults.set(false, forKey: camLock)
            userDefaults.set(5, forKey: upForce)
            userDefaults.set(-10, forKey: gravityValue)
            userDefaults.set(true, forKey: firstTime)
            userDefaults.set(false, forKey: darkMode)
            userDefaults.synchronize()
        }
        
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
            hitPhyNode.applyForce(SCNVector3(x:0, y:userDefaults.float(forKey: upForce), z:0), asImpulse: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
