//
//  CharactersViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/13.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit
import Yams

class CharactersViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let characters: [Character] = {
        let url = Bundle.main.bundleURL.appendingPathComponent("CharacterData/Characters.yml")
        let data = try! Data(contentsOf: url)
        let characters = try! YAMLDecoder().decode([Character].self, from: data)
        return characters
    }()

    lazy var characterBackgroundView: CharacterBackgroundView = {
        let navigationController: UINavigationController
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController = self.navigationController!
        } else {
            navigationController = splitViewController!.viewControllers[1] as! UINavigationController
        }

        let characterBackgroundView = CharacterBackgroundView(frame: navigationController.view.bounds)
        characterBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController.view.insertSubview(characterBackgroundView, at: 0)

        return characterBackgroundView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        switch segue.identifier {
        case "ShowDetail":
            let indexPath = tableView.indexPathForSelectedRow!
            let character = characters[indexPath.row]

            let url = Bundle.main.bundleURL.appendingPathComponent("CharacterData/\(character.next)")
            let data = try! Data(contentsOf: url)
            let sections = try! YAMLDecoder().decode([CharacterMove.Section].self, from: data)

            let detailViewController = (segue.destination as! UINavigationController).topViewController as! CharacterMovesViewController
            detailViewController.title = character.rowTitle
            detailViewController.sections = sections

            characterBackgroundView.imageView.image = UIImage(named: character.nextBackgroundImage)
        default:
            break
        }
    }

    func displayDetailViewController(_ detailViewController: CharacterMovesViewController, withSelectedIndexPath indexPath: IndexPath) {
        let character = characters[indexPath.row]

        let url = Bundle.main.bundleURL.appendingPathComponent("CharacterData/\(character.next)")
        let data = try! Data(contentsOf: url)
        let sections = try! YAMLDecoder().decode([CharacterMove.Section].self, from: data)

        detailViewController.title = character.rowTitle
        detailViewController.sections = sections

        characterBackgroundView.imageView.image = UIImage(named: character.nextBackgroundImage)
    }
}

extension CharactersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let character = characters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
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
            detailViewController.tableView.reloadData()
            detailViewController.tableView.flashScrollIndicators()
//            detailViewController.tableView.setContentOffset(.zero, animated: true)
        }
    }
}
