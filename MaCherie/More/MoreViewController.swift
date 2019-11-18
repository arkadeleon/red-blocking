//
//  MoreViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/15.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        switch cell?.reuseIdentifier {
        case R.reuseIdentifier.feedbackCell.identifier:
            if MFMailComposeViewController.canSendMail() {
                let mailCompose = MFMailComposeViewController()
                mailCompose.mailComposeDelegate = self
                mailCompose.setSubject("About MaCherie")
                mailCompose.setToRecipients(["leon@leonandvane.date"])
                present(mailCompose, animated: true, completion: nil)
            }
        case R.reuseIdentifier.clearDataStorageCell.identifier:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Clear data storage", style: .destructive, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
