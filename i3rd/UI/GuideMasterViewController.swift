//
//  GuideMasterViewController.swift
//  i3rd
//
//  Created by Leon Li on 2018/6/13.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

let GuideMasterViewControllerNextBackgroundImageKey = "NextBackgroundImage"

class GuideMasterViewController: PropertyListBasedViewController {
    lazy var bodyView: UIImageView = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let navigationBarHeight = navigationController!.navigationBar.bounds.height
            let bodyViewFrame = UIEdgeInsetsInsetRect(navigationController!.view.bounds, UIEdgeInsets(top: statusBarHeight + navigationBarHeight, left: 0, bottom: 0, right: 0))
            let bodyView = UIImageView(frame: bodyViewFrame)
            bodyView.contentMode = .scaleAspectFit
            bodyView.backgroundColor = .white
            navigationController!.view.insertSubview(bodyView, at: 0)
            return bodyView
        } else {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            let navigationBarHeight = detailNavigationController.navigationBar.bounds.height
            let bodyViewFrame = UIEdgeInsetsInsetRect(navigationController!.view.bounds, UIEdgeInsets(top: navigationBarHeight, left: 0, bottom: 0, right: 0))
            let bodyView = UIImageView(frame: bodyViewFrame)
            bodyView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
            bodyView.contentMode = .scaleAspectFit
            bodyView.backgroundColor = .white
            detailNavigationController.view.insertSubview(bodyView, at: 0)
            return bodyView
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "攻略"
        
        let propertyListURL = Bundle.main.bundleURL.appendingPathComponent("Guide.plist")
        let propertyListInfo = NSDictionary(contentsOf: propertyListURL)
        sections = propertyListInfo?[PropertyListBasedViewControllerSectionsKey] as? [Any]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            let detailViewController = detailNavigationController.topViewController as! GuideDetailViewController
            
            displayDetailViewController(detailViewController, withSelectedIndexPath: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let indexPath = tableView.indexPathForSelectedRow!
            let sectionInfo = sections[indexPath.section] as? NSDictionary
            let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
            let rowInfo = rows?[indexPath.row] as? NSDictionary
            let rowTitle = rowInfo?[PropertyListBasedViewControllerRowTitleKey] as? String
            let next = rowInfo?[PropertyListBasedViewControllerNextKey] as? String
            
            let detailPropertyListURL = Bundle.main.bundleURL.appendingPathComponent(next!)
            let detailPropertyListInfo = NSDictionary(contentsOf: detailPropertyListURL)
            let detailSections = detailPropertyListInfo?[PropertyListBasedViewControllerSectionsKey] as? NSArray
            
            let detailViewController = (segue.destination as! UINavigationController).topViewController as! GuideDetailViewController
            detailViewController.title = rowTitle
            detailViewController.sections = detailSections as? [Any]
        }
    }
    
    @IBAction func moreViewControllerUnwound(_ segue: UIStoryboardSegue) {
        
    }
    
    func displayDetailViewController(_ detailViewController: GuideDetailViewController, withSelectedIndexPath indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section] as? NSDictionary
        let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
        let rowInfo = rows?[indexPath.row] as? NSDictionary
        let rowTitle = rowInfo?[PropertyListBasedViewControllerRowTitleKey] as? String
        let next = rowInfo?[PropertyListBasedViewControllerNextKey] as? String
        let nextBackgroundImage = rowInfo?[GuideMasterViewControllerNextBackgroundImageKey] as? String
        
        let detailPropertyListURL = Bundle.main.bundleURL.appendingPathComponent(next!)
        let detailPropertyListInfo = NSDictionary(contentsOf: detailPropertyListURL)
        let detailSections = detailPropertyListInfo?[PropertyListBasedViewControllerSectionsKey] as? NSArray
        
        detailViewController.title = rowTitle
        detailViewController.sections = detailSections as? [Any]
        
        bodyView.image = UIImage(named: nextBackgroundImage!)
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
            
            let sectionInfo = sections[selectedIndexPath.row] as? NSDictionary
            let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
            let rowInfo = rows?[selectedIndexPath.row] as? NSDictionary
            let nextBackgroundImage = rowInfo?[GuideMasterViewControllerNextBackgroundImageKey] as? String
            bodyView.image = UIImage(named: nextBackgroundImage!)
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.accessoryType = .none;
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if UIDevice.current.userInterfaceIdiom == .pad && tableView.cellForRow(at: indexPath)?.isSelected == true {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            detailNavigationController.popToRootViewController(animated: true)
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            performSegue(withIdentifier: "ShowDetail", sender: nil)
        } else {
            let detailNavigationController = splitViewController?.viewControllers[1] as! UINavigationController
            detailNavigationController.popToRootViewController(animated: false)
            let detailViewController = detailNavigationController.topViewController as! GuideDetailViewController
            displayDetailViewController(detailViewController, withSelectedIndexPath: indexPath)
            detailViewController.tableView.contentOffset = .zero
            detailViewController.tableView.reloadData()
            detailViewController.tableView.flashScrollIndicators()
        }
    }
}
