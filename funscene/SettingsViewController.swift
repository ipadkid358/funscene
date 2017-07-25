//
//  SettingsViewController.swift
//  funscene
//
//  Created by ipad_kid on 7/17/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

import SceneKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var settingsView: UITableView!
    @IBOutlet weak var settingsNavBar: UINavigationItem!
    @IBOutlet var labelLabels: [UILabel]!
    @IBOutlet var hueImages: [UIImageView]!
    @IBOutlet var tableCells: [UITableViewCell]!
    
    @IBOutlet weak var scnStatsSwitch: UISwitch!
    @IBOutlet weak var camLockSwitch: UISwitch!
    @IBOutlet weak var forceSlider: UISlider!
    @IBOutlet weak var gravitySlider: UISlider!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var skyColorSlider: UISlider!
    @IBOutlet weak var floorColorSlider: UISlider!
    @IBOutlet weak var cubeColorSlider: UISlider!
    @IBOutlet weak var showHeightSwitch: UISwitch!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let scnStats: String = "scnStats"
    private let camLock: String = "camLock"
    private let upForce: String = "upForce"
    private let gravityValue: String = "gravityValue"
    private let darkMode: String = "darkMode"
    private let skyColor: String = "skyColor"
    private let floorColor: String = "floorColor"
    private let cubeColor: String = "cubeColor"
    private let showHeight: String = "showHeight"
    
    func setViewColors() {
        let backgroundColor: UIColor
        let labelColor: UIColor
        let darkPrefix: String
        if darkModeSwitch.isOn {
            backgroundColor = .black
            labelColor = .white
            darkPrefix = "dark"
        } else {
            backgroundColor = .white
            labelColor = .black
            darkPrefix = ""
        }
        
        setNeedsStatusBarAppearanceUpdate()
        settingsView.backgroundColor = backgroundColor
        settingsView.separatorColor = backgroundColor

        for tableCell in tableCells {
            tableCell.backgroundColor = backgroundColor
        }
        
        for labelLabel in labelLabels {
            labelLabel.textColor = labelColor
        }
        
        skyColorSlider.value = userDefaults.float(forKey: "\(darkPrefix)\(skyColor)")
        floorColorSlider.value = userDefaults.float(forKey: "\(darkPrefix)\(floorColor)")
        cubeColorSlider.value = userDefaults.float(forKey: "\(darkPrefix)\(cubeColor)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnStatsSwitch.isOn = userDefaults.bool(forKey: scnStats)
        camLockSwitch.isOn = userDefaults.bool(forKey: camLock)
        forceSlider.value = userDefaults.float(forKey: upForce)
        gravitySlider.value = 0-userDefaults.float(forKey: gravityValue)
        darkModeSwitch.isOn = userDefaults.bool(forKey: darkMode)
        showHeightSwitch.isOn = userDefaults.bool(forKey: showHeight)
        
        for hueImage in hueImages {
            hueImage.layer.cornerRadius = 2.5
        }
        
        for tableCell in tableCells {
            tableCell.selectionStyle = .none
        }

        
        let colorSliders: [UISlider] = [skyColorSlider, floorColorSlider, cubeColorSlider]
        for colorSlider in colorSliders {
            colorSlider.setThumbImage(#imageLiteral(resourceName: "normalSlider"), for: .normal)
            colorSlider.setThumbImage(#imageLiteral(resourceName: "highlightedSlider"), for: .highlighted)
        }
        
        setViewColors()
    }
    
    func saveColorSliders(darkPrefix: String) {
        userDefaults.set(skyColorSlider.value, forKey: "\(darkPrefix)\(skyColor)")
        userDefaults.set(floorColorSlider.value, forKey: "\(darkPrefix)\(floorColor)")
        userDefaults.set(cubeColorSlider.value, forKey: "\(darkPrefix)\(cubeColor)")
        userDefaults.synchronize()
    }
    
    @IBAction func darkModeHit() {
        if darkModeSwitch.isOn {
            saveColorSliders(darkPrefix: "")
        } else {
            saveColorSliders(darkPrefix: "dark")
        }
        
        setViewColors()
    }
    
    @IBAction func close() {
        userDefaults.set(scnStatsSwitch.isOn, forKey: scnStats)
        userDefaults.set(camLockSwitch.isOn, forKey: camLock)
        userDefaults.set(forceSlider.value, forKey: upForce)
        userDefaults.set(0-gravitySlider.value, forKey: gravityValue)
        userDefaults.set(darkModeSwitch.isOn, forKey: darkMode)
        userDefaults.set(showHeightSwitch.isOn, forKey: showHeight)
        
        if darkModeSwitch.isOn {
            saveColorSliders(darkPrefix: "dark")
        } else {
            saveColorSliders(darkPrefix: "")
        }
        
        let gameViewController: GameViewController? = presentingViewController as? GameViewController
        guard let gameVC = gameViewController else { return }
        gameVC.setSceneSettings()
        
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return darkModeSwitch.isOn ? .lightContent : .default
    }
    
}
