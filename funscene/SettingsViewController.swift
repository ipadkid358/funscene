//
//  SettingsViewController.swift
//  funscene
//
//  Created by ipad_kid on 7/17/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

import SceneKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var showStats: UILabel!
    @IBOutlet weak var camLockLabel: UILabel!
    @IBOutlet weak var upForceLabel: UILabel!
    @IBOutlet weak var gravityLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    @IBOutlet weak var scnStatsSwitch: UISwitch!
    @IBOutlet weak var camLockSwitch: UISwitch!
    @IBOutlet weak var forceSlider: UISlider!
    @IBOutlet weak var gravitySlider: UISlider!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let scnStats: String = "scnStats"
    private let camLock: String = "camLock"
    private let upForce: String = "upForce"
    private let gravityValue: String = "gravityValue"
    private let darkMode: String = "darkMode"
    
    @IBAction func setViewColors() {
        let background: UIColor
        let label: UIColor
        if darkModeSwitch.isOn {
            background = .black
            label = .white
        } else {
            background = .white
            label = .black
        }
        setNeedsStatusBarAppearanceUpdate()
        settingsView.backgroundColor = background
        showStats.textColor = label
        camLockLabel.textColor = label
        camLockLabel.textColor = label
        upForceLabel.textColor = label
        gravityLabel.textColor = label
        darkModeLabel.textColor = label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnStatsSwitch.isOn = userDefaults.bool(forKey: scnStats)
        camLockSwitch.isOn = userDefaults.bool(forKey: camLock)
        forceSlider.value = userDefaults.float(forKey: upForce)
        gravitySlider.value = 0-userDefaults.float(forKey: gravityValue)
        darkModeSwitch.isOn = userDefaults.bool(forKey: darkMode)
        setViewColors()
    }
    
    @IBAction func close() {
        userDefaults.set(scnStatsSwitch.isOn, forKey: scnStats)
        userDefaults.set(camLockSwitch.isOn, forKey: camLock)
        userDefaults.set(forceSlider.value, forKey: upForce)
        userDefaults.set(0-gravitySlider.value, forKey: gravityValue)
        userDefaults.set(darkModeSwitch.isOn, forKey: darkMode)
        userDefaults.synchronize()
        
        var gameViewController: GameViewController? {
            return presentingViewController as? GameViewController
        }
        
        guard let gameVC = gameViewController else { return }
        gameVC.setSceneSettings()
        
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return darkModeSwitch.isOn ? .lightContent : .default
    }
    
}


