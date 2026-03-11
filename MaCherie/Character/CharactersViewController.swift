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

    private let characterRepository = CharacterRepository()
    private let moveRepository = MoveRepository()

    private lazy var characters: [Character] = {
        do {
            return try characterRepository.loadCharacters()
        } catch {
            assertionFailure("Failed to load character list: \(error)")
            return []
        }
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

        if UIDevice.current.userInterfaceIdiom == .pad, !characters.isEmpty {
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

            let detailViewController = (segue.destination as! UINavigationController).topViewController as! CharacterMovesViewController
            detailViewController.title = character.rowTitle
            detailViewController.sections = loadSections(for: character)

            characterBackgroundView.imageView.image = characterRepository.backgroundImage(for: character)
        default:
            break
        }
    }

    func displayDetailViewController(_ detailViewController: CharacterMovesViewController, withSelectedIndexPath indexPath: IndexPath) {
        let character = characters[indexPath.row]

        detailViewController.title = character.rowTitle
        detailViewController.sections = loadSections(for: character)

        characterBackgroundView.imageView.image = characterRepository.backgroundImage(for: character)
    }

    private func loadSections(for character: Character) -> [CharacterMove.Section] {
        do {
            return try moveRepository.loadSections(for: character)
        } catch {
            assertionFailure("Failed to load move sections for \(character.rowTitle): \(error)")
            return []
        }
    }
}

extension CharactersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let character = characters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
        cell.rowImageView.image = characterRepository.rowImage(for: character)
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
