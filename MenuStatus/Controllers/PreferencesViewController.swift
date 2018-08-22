//
//  PreferencesViewController.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/22/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa

var profileStatuses = [
    Profile(statusText: "Working remotely", statusEmoji: ":house_with_garden:"),
    Profile(statusText: "I'm working at the office", statusEmoji: ":office:"),
    Profile(statusText: "I'm Blocked", statusEmoji: ":no_entry_sign:")
]

class PreferencesViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statusTextTextField: NSTextField!
    @IBOutlet weak var statusEmojiShortcodeTextField: NSTextField!
    @IBOutlet weak var statusEmojiUnicodeTextField: NSTextField!
    @IBOutlet weak var statusEmojiLabelTextField: NSTextField!
    var selectedProfileStatus: Profile! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        if (self.title! == "Statuses") {
            selectedProfileStatus = profileStatuses[0]
            updateStatusFields()
        }
    }
}

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        NSLog(String(profileStatuses.count))
        return profileStatuses.count
    }
}

extension PreferencesViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let StatusTextCell = "StatusText"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""

        let item = profileStatuses[row]

        if tableColumn == tableView.tableColumns[0] {
            text = "\(item.emojiCode()) \(item.statusText)"
            cellIdentifier = CellIdentifiers.StatusTextCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = tableView.selectedRowIndexes.first
        selectedProfileStatus = profileStatuses[selectedItem!]
        updateStatusFields()
    }

    func updateStatusFields() {
        statusTextTextField.stringValue = selectedProfileStatus.statusText
        statusEmojiUnicodeTextField.stringValue = String(format: "%X", selectedProfileStatus.emojiCode().unicodeScalars.first!.value)
        statusEmojiShortcodeTextField.stringValue = selectedProfileStatus.statusEmoji
        statusEmojiLabelTextField.stringValue = selectedProfileStatus.emojiCode()
    }
}
