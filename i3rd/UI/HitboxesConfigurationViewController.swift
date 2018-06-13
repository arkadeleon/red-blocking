//
//  HitboxesConfigurationViewController.swift
//  i3rd
//
//  Created by Leon Li on 2018/6/13.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class HitboxesConfigurationViewController: UITableViewController {
    @IBOutlet var playerControl: UISegmentedControl!
    @IBOutlet var passiveHitboxesSwitch: UISwitch!
    @IBOutlet var otherVulnerabilityHitboxesSwitch: UISwitch!
    @IBOutlet var activeHitboxesSwitch: UISwitch!
    @IBOutlet var throwHitboxesSwitch: UISwitch!
    @IBOutlet var throwableHitboxesSwitch: UISwitch!
    @IBOutlet var pushHitboxesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerChanged(playerControl)
        
        let userDefaults = UserDefaults.standard
        
        passiveHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredPassiveHitboxRGBColorKey), alpha:0.5)
        otherVulnerabilityHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredOtherVulnerabilityHitboxRGBColorKey), alpha:0.5)
        activeHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredActiveHitboxRGBColorKey), alpha:0.5)
        throwHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredThrowHitboxRGBColorKey), alpha:0.5)
        throwableHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredThrowableHitboxRGBColorKey), alpha:0.5)
        pushHitboxesSwitch.onTintColor = UIColor(rgb: userDefaults.integer(forKey: PreferredPushHitboxRGBColorKey), alpha:0.5)
    }
    
    @IBAction func playerChanged(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        
        switch (self.playerControl.selectedSegmentIndex) {
        case 0:
            passiveHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1PassiveHitboxHiddenKey), animated:true)
            otherVulnerabilityHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey), animated:true)
            activeHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1ActiveHitboxHiddenKey), animated:true)
            throwHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1ThrowHitboxHiddenKey), animated:true)
            throwableHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1ThrowableHitboxHiddenKey), animated:true)
            pushHitboxesSwitch.setOn(userDefaults.bool(forKey: Player1PushHitboxHiddenKey), animated:true)
        case 1:
            passiveHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2PassiveHitboxHiddenKey), animated:true)
            otherVulnerabilityHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey), animated:true)
            activeHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2ActiveHitboxHiddenKey), animated:true)
            throwHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2ThrowHitboxHiddenKey), animated:true)
            throwableHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2ThrowableHitboxHiddenKey), animated:true)
            pushHitboxesSwitch.setOn(userDefaults.bool(forKey: Player2PushHitboxHiddenKey), animated:true)
        default:
            break
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        let control = sender as! UISwitch
        let index = playerControl.selectedSegmentIndex * tableView.numberOfRows(inSection: 0) + control.tag
        let userDefaults = UserDefaults.standard
        
        switch index {
        case 1:
            userDefaults.set(control.isOn, forKey:Player1PassiveHitboxHiddenKey)
        case 2:
            userDefaults.set(control.isOn, forKey:Player1OtherVulnerabilityHitboxHiddenKey)
        case 3:
            userDefaults.set(control.isOn, forKey:Player1ActiveHitboxHiddenKey)
        case 4:
            userDefaults.set(control.isOn, forKey:Player1ThrowHitboxHiddenKey)
        case 5:
            userDefaults.set(control.isOn, forKey:Player1ThrowableHitboxHiddenKey)
        case 6:
            userDefaults.set(control.isOn, forKey:Player1PushHitboxHiddenKey)
        case 7:
            userDefaults.set(control.isOn, forKey:Player2PassiveHitboxHiddenKey)
        case 8:
            userDefaults.set(control.isOn, forKey:Player2OtherVulnerabilityHitboxHiddenKey)
        case 9:
            userDefaults.set(control.isOn, forKey:Player2ActiveHitboxHiddenKey)
        case 10:
            userDefaults.set(control.isOn, forKey:Player1ThrowHitboxHiddenKey)
        case 11:
            userDefaults.set(control.isOn, forKey:Player1ThrowableHitboxHiddenKey)
        case 12:
            userDefaults.set(control.isOn, forKey:Player2PushHitboxHiddenKey)
        default:
            break
        }
    }
}
