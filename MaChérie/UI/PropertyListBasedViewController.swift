//
//  PropertyListBasedViewController.swift
//  MaChérie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

let PropertyListBasedViewControllerSectionsKey = "Sections"
let PropertyListBasedViewControllerSectionTitleKey = "SectionTitle"
let PropertyListBasedViewControllerRowsKey = "Rows"
let PropertyListBasedViewControllerRowImageKey = "RowImage"
let PropertyListBasedViewControllerRowTitleKey = "RowTitle"
let PropertyListBasedViewControllerRowDetailKey = "RowDetail"
let PropertyListBasedViewControllerNextKey = "Next"
let PropertyListBasedViewControllerPresentedKey = "Presented"

class PropertyListBasedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIDataSourceModelAssociation {
    @IBOutlet var tableView: UITableView!
    
    @objc var sections = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.register(UINib(nibName: "PropertyListBasedTableViewCell", bundle: nil), forCellReuseIdentifier: "PropertyListBasedTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func configureCell(_ cell: PropertyListBasedTableViewCell, forRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section] as? NSDictionary
        let rows = sectionInfo?[PropertyListBasedViewControllerRowsKey] as? NSArray
        let rowInfo = rows?[indexPath.row] as? NSDictionary
        let rowImage = rowInfo?[PropertyListBasedViewControllerRowImageKey] as? String
        let rowTitle = rowInfo?[PropertyListBasedViewControllerRowTitleKey] as? String
        let rowDetail = rowInfo?[PropertyListBasedViewControllerRowDetailKey] as? String
        
        cell.leftImageView.image = rowImage != nil ? UIImage(named: rowImage!) : nil
        cell.leftLabel.text = rowTitle
        cell.rightLabel.text = rowDetail
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sections[section] as! NSDictionary
        let rows = sectionInfo[PropertyListBasedViewControllerRowsKey] as! NSArray
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyListBasedTableViewCell", for: indexPath) as! PropertyListBasedTableViewCell
        configureCell(cell, forRowAt: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = sections[section] as! NSDictionary
        let sectionTitle = sectionInfo[PropertyListBasedViewControllerSectionTitleKey] as? String
        return sectionTitle
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as! PropertyListBasedTableViewCell
        return cell.canBeSelected() ? indexPath : nil
    }
    
    // MARK: - Data Source Model Association
    
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
