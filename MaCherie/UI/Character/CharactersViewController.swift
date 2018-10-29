//
//  CharactersViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/13.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class CharactersViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let characters: [Character] = {
        let url = Bundle.main.bundleURL.appendingPathComponent("Characters.plist")
        let data = try! Data(contentsOf: url)
        let characters = try! PropertyListDecoder().decode([Character].self, from: data)
        return characters
    }()
    
    lazy var bodyView: UIImageView = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navigationBarHeight = navigationController!.navigationBar.bounds.height
            let bodyViewFrame = UIEdgeInsetsInsetRect(navigationController!.view.bounds, UIEdgeInsets(top: statusBarHeight + navigationBarHeight, left: 0, bottom: 0, right: 0))
            let bodyView = UIImageView(frame: bodyViewFrame)
            bodyView.contentMode = .scaleAspectFit
            bodyView.backgroundColor = R.color.backgroundColor()
            navigationController!.view.insertSubview(bodyView, at: 0)
            return bodyView
        } else {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            let navigationBarHeight = detailNavigationController.navigationBar.bounds.height
            let bodyViewFrame = UIEdgeInsetsInsetRect(navigationController!.view.bounds, UIEdgeInsets(top: navigationBarHeight, left: 0, bottom: 0, right: 0))
            let bodyView = UIImageView(frame: bodyViewFrame)
            bodyView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
            bodyView.contentMode = .scaleAspectFit
            bodyView.backgroundColor = R.color.backgroundColor()
            detailNavigationController.view.insertSubview(bodyView, at: 0)
            return bodyView
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Characters"
        
        tableView.register(R.nib.characterCell)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            let detailViewController = detailNavigationController.topViewController as! CharacterMovesViewController
            
            displayDetailViewController(detailViewController, withSelectedIndexPath: indexPath)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let indexPath = tableView.indexPathForSelectedRow!
            let character = characters[indexPath.row]
            
            let url = Bundle.main.bundleURL.appendingPathComponent(character.next)
            let data = try! Data(contentsOf: url)
            let sections = try! PropertyListDecoder().decode([CharacterMove.Section].self, from: data)
            
            let detailViewController = (segue.destination as! UINavigationController).topViewController as! CharacterMovesViewController
            detailViewController.title = character.rowTitle
            detailViewController.sections = sections
            
            bodyView.image = UIImage(named: character.nextBackgroundImage)
        }
    }
    
    func displayDetailViewController(_ detailViewController: CharacterMovesViewController, withSelectedIndexPath indexPath: IndexPath) {
        let character = characters[indexPath.row]
        
        let url = Bundle.main.bundleURL.appendingPathComponent(character.next)
        let data = try! Data(contentsOf: url)
        let sections = try! PropertyListDecoder().decode([CharacterMove.Section].self, from: data)
        
        detailViewController.title = character.rowTitle
        detailViewController.sections = sections
        
        bodyView.image = UIImage(named: character.nextBackgroundImage)
    }
    
    // MARK: - State Restoration
    
    let GuideMasterViewControllerSelectedIndexPathKey = "SelectedIndexPath"
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(tableView.indexPathForSelectedRow, forKey: GuideMasterViewControllerSelectedIndexPathKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        if let selectedIndexPath = coder.decodeObject(forKey: GuideMasterViewControllerSelectedIndexPathKey) as? IndexPath {
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
            
            let character = characters[selectedIndexPath.row]
            bodyView.image = UIImage(named: character.nextBackgroundImage)
        }
    }
}

extension CharactersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let character = characters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.characterCell, for: indexPath)!
        cell.rowImageView.image = UIImage(named: character.rowImage)
        cell.rowTitleLabel.text = character.rowTitle
        return cell
    }
}

extension CharactersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = traitCollection.horizontalSizeClass == .compact ? .disclosureIndicator : .none
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if UIDevice.current.userInterfaceIdiom == .pad && tableView.cellForRow(at: indexPath)?.isSelected == true {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            detailNavigationController.popToRootViewController(animated: true)
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            performSegue(withIdentifier: "ShowDetail", sender: nil)
        } else {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            detailNavigationController.popToRootViewController(animated: false)
            let detailViewController = detailNavigationController.topViewController as! CharacterMovesViewController
            displayDetailViewController(detailViewController, withSelectedIndexPath: indexPath)
            detailViewController.tableView.contentOffset = .zero
            detailViewController.tableView.reloadData()
            detailViewController.tableView.flashScrollIndicators()
        }
    }
}

extension CharactersViewController: UIDataSourceModelAssociation {
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
