//
//  CharacterMovesViewController.swift
//  MaChérie
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

class CharacterMovesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var sections: [CharacterMove.Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableViewBackgroundView = UIView(frame: tableView.bounds)
        tableViewBackgroundView.backgroundColor = .clear
        tableView.backgroundView = tableViewBackgroundView
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
        
        navigationController?.delegate = AppDelegate.shared
        
        tableView.register(R.nib.characterMoveCell)
        tableView.register(R.nib.characterMoveDetailCell)
        tableView.register(R.nib.characterMoveFramesCell)
        tableView.register(R.nib.characterSupplementaryCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue {
            let indexPath = tableView.indexPathForSelectedRow!
            let characterMove = sections[indexPath.section].rows[indexPath.row]
            
            let player = (segue.destination as! UINavigationController).topViewController as! SkillMotionPlayerViewController
            player.delegate = self
            player.characterCode = characterMove.presented!.characterCode
            player.skillCode = characterMove.presented!.skillCode
            player.title = characterMove.presented!.skillName
        }
    }
    
    // MARK: - State Restoration
    
//    let GuideDetailViewControllerTitleKey = "Title"
//    let GuideDetailViewControllerSelectedIndexPathKey = "SelectedIndexPath"
//
//    override func encodeRestorableState(with coder: NSCoder) {
//        super.encodeRestorableState(with: coder)
//
//        coder.encode(title, forKey: GuideDetailViewControllerTitleKey)
//        coder.encode(sections, forKey: PropertyListBasedViewControllerSectionsKey)
//        coder.encode(tableView.indexPathForSelectedRow, forKey: GuideDetailViewControllerSelectedIndexPathKey)
//    }
//
//    override func decodeRestorableState(with coder: NSCoder) {
//        title = coder.decodeObject(forKey: GuideDetailViewControllerTitleKey) as? String
//        sections = coder.decodeObject(forKey: PropertyListBasedViewControllerSectionsKey) as! NSArray
//        if let selectedIndexPath = coder.decodeObject(forKey: GuideDetailViewControllerSelectedIndexPathKey) as? IndexPath {
//            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
//        }
//    }
}

extension CharacterMovesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let characterMove = sections[indexPath.section].rows[indexPath.row]
        if let presented = characterMove.presented {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.characterMoveFramesCell, for: indexPath)!
            cell.rowTitleLabel.text = characterMove.rowTitle
            return cell
        } else if let next = characterMove.next {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.characterMoveCell, for: indexPath)!
            cell.rowTitleLabel.text = characterMove.rowTitle
            return cell
        } else if let detail = characterMove.rowDetail {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.characterMoveDetailCell, for: indexPath)!
            cell.rowTitleLabel.text = characterMove.rowTitle
            cell.rowDetailLabel.text = characterMove.rowDetail
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.characterSupplementaryCell, for: indexPath)!
            cell.rowTitleLabel.text = characterMove.rowTitle
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].sectionTitle
    }
}

extension CharacterMovesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characterMove = sections[indexPath.section].rows[indexPath.row]
        if let presented = characterMove.presented {
            let presentedViewControllerName = presented.viewController
            if presentedViewControllerName == "FramesPlayerViewController" {
                performSegue(withIdentifier: GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue, sender: self)
            }
        } else if let next = characterMove.next {
            let nextViewController = storyboard?.instantiateViewController(withIdentifier: "GuideDetailViewController") as! CharacterMovesViewController
            nextViewController.title = characterMove.rowTitle
            nextViewController.sections = next
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}

extension CharacterMovesViewController: UIDataSourceModelAssociation {
    func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String? {
        return nil
    }
    
    func indexPathForElement(withModelIdentifier identifier: String, in view: UIView) -> IndexPath? {
        let components = identifier.components(separatedBy: ", ")
        let section = Int(components[0])!
        let row = Int(components[1])!
        return IndexPath(row: row, section: section)
    }
}

extension CharacterMovesViewController: SkillMotionPlayerViewControllerDelegate {
    func willDismiss(_ skillMotionPlayerViewController: SkillMotionPlayerViewController!) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
}
