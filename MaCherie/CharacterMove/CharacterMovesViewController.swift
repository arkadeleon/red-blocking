//
//  CharacterMovesViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowMotionPlayer":
            let indexPath = tableView.indexPathForSelectedRow!

            let player = (segue.destination as! UINavigationController).topViewController as! MotionPlayerViewController
            let characterMove = sections[indexPath.section].rows[indexPath.row]
            player.characterCode = characterMove.presented!.characterCode
            player.skillCode = characterMove.presented!.skillCode
            player.title = characterMove.presented!.skillName

            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
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
        if let _ = characterMove.presented {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterMoveFramesCell", for: indexPath) as! CharacterMoveFramesCell
            cell.rowTitleLabel.text = characterMove.rowTitle
            return cell
        } else if let _ = characterMove.next {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterMoveCell", for: indexPath) as! CharacterMoveCell
            cell.rowTitleLabel.text = characterMove.rowTitle
            return cell
        } else if let _ = characterMove.rowDetail {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterMoveDetailCell", for: indexPath) as! CharacterMoveDetailCell
            cell.rowTitleLabel.text = characterMove.rowTitle
            cell.rowDetailLabel.text = characterMove.rowDetail
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSupplementaryCell", for: indexPath) as! CharacterSupplementaryCell
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
                performSegue(withIdentifier: "ShowMotionPlayer", sender: self)
            }
        } else if let next = characterMove.next {
            let nextViewController = storyboard?.instantiateViewController(withIdentifier: "CharacterMovesViewController") as! CharacterMovesViewController
            nextViewController.title = characterMove.rowTitle
            nextViewController.sections = next
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
