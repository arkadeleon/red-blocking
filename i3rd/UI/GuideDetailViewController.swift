//
//  GuideDetailViewController.swift
//  i3rd
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

let GuideDetailViewControllerCharacterCodeKey = "CharacterCode"
let GuideDetailViewControllerSkillCodeKey = "SkillCode"
let GuideDetailViewControllerSkillNameKey = "SkillName"
let GuideDetailViewControllerViewControllerKey = "ViewController"
let GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue = "PresentSkillMotionPlayerViewController"

class GuideDetailViewController: PropertyListBasedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tableViewBackgroundView = UIView(frame: tableView.bounds)
//        tableViewBackgroundView.backgroundColor = .clear
//        tableView.backgroundView = tableViewBackgroundView
//        tableView.backgroundColor = .clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue {
            let indexPath = tableView.indexPathForSelectedRow!
            let sectionInfo = sections[indexPath.section] as? NSDictionary
            let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
            let rowInfo = rows?[indexPath.row] as? NSDictionary
            let presented = rowInfo?[PropertyListBasedViewControllerPresentedKey] as? NSDictionary
            
            let player = (segue.destination as! UINavigationController).topViewController as! SkillMotionPlayerViewController
            player.delegate = self
            player.characterCode = presented?[GuideDetailViewControllerCharacterCodeKey] as? String
            player.skillCode = presented?[GuideDetailViewControllerSkillCodeKey] as? String
            player.title = presented?[GuideDetailViewControllerSkillNameKey] as? String
        }
    }
    
    // MARK: - State Restoration
    
    let GuideDetailViewControllerTitleKey = "Title"
    let GuideDetailViewControllerSelectedIndexPathKey = "SelectedIndexPath"
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(title, forKey: GuideDetailViewControllerTitleKey)
        coder.encode(sections, forKey: PropertyListBasedViewControllerSectionsKey)
        coder.encode(tableView.indexPathForSelectedRow, forKey: GuideDetailViewControllerSelectedIndexPathKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        title = coder.decodeObject(forKey: GuideDetailViewControllerTitleKey) as? String
        sections = coder.decodeObject(forKey: PropertyListBasedViewControllerSectionsKey) as! NSArray
        if let selectedIndexPath = coder.decodeObject(forKey: GuideDetailViewControllerSelectedIndexPathKey) as? IndexPath {
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section] as? NSDictionary
        let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
        let rowInfo = rows?[indexPath.row] as? NSDictionary
        let rowTitle = rowInfo?[PropertyListBasedViewControllerRowTitleKey] as? String
        
        if let next = rowInfo?[PropertyListBasedViewControllerNextKey] {
            let propertyListInfo: NSDictionary
            if next is String {
                let propertyListURL = Bundle.main.bundleURL.appendingPathComponent(next as! String)
                propertyListInfo = NSDictionary(contentsOf: propertyListURL)!
            } else {
                propertyListInfo = next as! NSDictionary
            }
            
            let nextSectionsInfo = propertyListInfo[PropertyListBasedViewControllerSectionsKey] as! NSArray
            
            let nextViewController = storyboard?.instantiateViewController(withIdentifier: "GuideDetailViewController") as! GuideDetailViewController
            nextViewController.title = rowTitle
            nextViewController.sections = nextSectionsInfo
            navigationController?.pushViewController(nextViewController, animated: true)
        } else if let presented = rowInfo?[PropertyListBasedViewControllerPresentedKey] as? NSDictionary {
            let presentedViewControllerName = presented[GuideDetailViewControllerViewControllerKey] as? String
            if presentedViewControllerName == "FramesPlayerViewController" {
                performSegue(withIdentifier: GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue, sender: self)
            }
        }
    }
}

extension GuideDetailViewController: SkillMotionPlayerViewControllerDelegate {
    func willDismiss(_ skillMotionPlayerViewController: SkillMotionPlayerViewController!) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
}
