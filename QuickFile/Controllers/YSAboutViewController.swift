//
//  YSAboutViewController.swift
//  QuickFile
//
//  Created by Yurii Boiko on 12/13/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices
import SwiftMessages

class YSAboutViewController: UITableViewController {
    private let emailtoIdentifier = "emailto"
    private let githubIdentifier = "github"
    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        var versionComplex = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionComplex = version
        }
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionComplex += " (\(buildNumber))  "
        }
        versionLabel.text = versionComplex
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath), let cellId = cell.reuseIdentifier {
            switch cellId {
            case emailtoIdentifier:
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    composeVC.setToRecipients([YSConstants.kDeveloperMail])
                    composeVC.setSubject("QuickFile Feedback")
                    composeVC.setMessageBody("Hi! I'd like to say", isHTML: false)
                    present(composeVC, animated: true, completion: nil)
                } else {
                    let error = YSError.init(errorType: .none, messageType: .warning, title: "Cannot compose mail", message: "", buttonTitle: "")
                    let message = SwiftMessages.createMessage(error)
                    SwiftMessages.showDefaultMessage(message)
                }
            case githubIdentifier:
                if let url = URL(string: YSConstants.kProjectURL) {
                    let safari = SFSafariViewController(url: url)
                    present(safari, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
}

extension YSAboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            logDefault(.View, .Error, "-About: Error composing mail: " + error.localizedDescription)
        }
        controller.dismiss(animated: true, completion: nil)
        switch result {
        case .failed:
            let error = YSError.init(errorType: .none, messageType: .error, title: "Failed to compose mail", message: "", buttonTitle: "")
            let message = SwiftMessages.createMessage(error)
            SwiftMessages.showDefaultMessage(message)
        case .sent:
            let error = YSError.init(errorType: .none, messageType: .success, title: "Sent!", message: "", buttonTitle: "")
            let message = SwiftMessages.createMessage(error)
            SwiftMessages.showDefaultMessage(message)
        default:
            break
        }
    }
}
