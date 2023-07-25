//
//  SettingsViewController.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 9/12/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import ArcXP
import os

class SettingsViewController: UIViewController {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: SettingsViewController.self))
    private let softwareVersionsTableViewCell = "SoftwareVersionsTableViewCell"
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let softwareVersionsTableViewCellNib = UINib(nibName: softwareVersionsTableViewCell, bundle: .main)
        tableView.register(softwareVersionsTableViewCellNib, forCellReuseIdentifier: softwareVersionsTableViewCell)
    }
}

// MARK: - Table View

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row == 2 {
            guard let softwareVersionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: softwareVersionsTableViewCell,
                                                                                    for: indexPath) as? SoftwareVersionsTableViewCell else {
                Self.logger.error("\(UserFacingStrings.cellUIError)")
                return .errorCell(message: UserFacingStrings.cellUIError)
            }
            
            softwareVersionsTableViewCell.configureVersions(app: "\(Bundle.main.appVersionLong)",
                                                            content: "\(ArcXPContentManager.version)",
                                                            video: "\(ArcMediaPlayerSDK.versionString)")
            cell = softwareVersionsTableViewCell
        } else {
            cell = UITableViewCell()
            cell.textLabel?.text = indexPath.row == 0 ? UserFacingStrings.tos : UserFacingStrings.privacyPolicy
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 260
        } else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Task {
            switch indexPath.row {
            case 0:
                // Terms of Service
                do {
                    let termsOfServiceContent = try await ContentProvider.fetchStory(id: Constants.termsOfServiceANSId)
                    guard let contentElements = termsOfServiceContent.contentElements,
                          let text = parseContent(from: contentElements) else {
                        Self.logger.error("\(UserFacingStrings.tosParseError)")
                        presentErrorAlert(message: UserFacingStrings.tosParseError)
                        return
                    }
                    presentTextDetailViewController(for: UserFacingStrings.tos, with: text)
                    return
                } catch {
                    let errorMessage = "\(UserFacingStrings.defaultContentFetchErrorMessage) \(error.localizedDescription)"
                    Self.logger.error("\(errorMessage)")
                    presentErrorAlert(message: errorMessage)
                }
            case 1:
                // Privacy Policy
                do {
                    let privacyPolicyContent = try await ContentProvider.fetchStory(id: Constants.privacyPolicyANSId)
                    guard let contentElements = privacyPolicyContent.contentElements,
                          let text = parseContent(from: contentElements) else {
                        Self.logger.error("\(UserFacingStrings.ppParseError)")
                        presentErrorAlert(message: UserFacingStrings.ppParseError)
                        return
                    }
                    
                    presentTextDetailViewController(for: UserFacingStrings.privacyPolicy, with: text)
                    return
                } catch {
                    let errorMessage = "\(UserFacingStrings.defaultContentFetchErrorMessage) \(error.localizedDescription)"
                    Self.logger.error("\(errorMessage)")
                    presentErrorAlert(message: errorMessage)
                }
            default:
                return
            }
        }
    }
    
    private func parseContent(from elements: [ContentElement]) -> NSAttributedString? {
        var dataString = ""
        for element in elements {
            if let typeString = element.type {
                switch typeString {
                case ContentType.text.rawValue:
                    if let textContent = element.content {
                        dataString += "\(textContent) "
                    } else {
                        Self.logger.error("Error getting text content from parsed content elements.")
                    }
                default:
                    // On all other cases, don't add any text to the string.
                    break
                }
            }
        }
        
        guard let attrString = dataString.htmlAttributedString() else {
            Self.logger.error("Error converting html string to an attributed string.")
            return nil
        }
        
        return attrString
    }
    
    private func presentTextDetailViewController(for policy: String, with text: NSAttributedString) {
        let textDetailViewController = TextDetailViewController.instantiate(title: policy, text: text)
        present(textDetailViewController, animated: true)
    }
}
