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
    @IBOutlet weak var tableViewActionSegmentedControl: NSSegmentedControl!
    var selectedProfileStatus: Profile! = nil
    var selectedProfileIndex: Int! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        if (self.title! == "Statuses") {
            selectedProfileStatus = profileStatuses[0]
            selectedProfileIndex = 0
            updateStatusFields()
        }
    }

    @IBAction func segmentClickAction(_ sender: AnyObject) {
        NSLog("segmentClickAction")
        let selectedSegment: Int! = sender.selectedSegment!
        switch (selectedSegment) {
        case 0:
            profileStatuses.append(Profile(statusText: "", statusEmoji: ""))
            tableView.beginUpdates()
            let newStatusIndex = IndexSet(integer: profileStatuses.count-1)
            tableView.insertRows(at: newStatusIndex, withAnimation: NSTableView.AnimationOptions.effectFade)
            tableView.endUpdates()
            tableView.selectRowIndexes(newStatusIndex, byExtendingSelection: false)
            statusTextTextField.becomeFirstResponder()
            break
        case 1:
            let selectedItem = tableView.selectedRowIndexes.first
            profileStatuses.remove(at: selectedItem!)
            tableView.beginUpdates()
            let selectedItemIndex = IndexSet(integer: selectedItem!)
            tableView.removeRows(at: selectedItemIndex, withAnimation: NSTableView.AnimationOptions.effectFade)
            tableView.endUpdates()
            let newSelectedItemIndex = IndexSet(integer: selectedItem! == 0 ? 0 : selectedItem!)
            tableView.selectRowIndexes(newSelectedItemIndex, byExtendingSelection: false)
        default:
            break
        }
    }
}

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
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
            let displayEmoji = item.recognizedEmoji ? item.emojiCode : "\u{2753}"
            text = "\(displayEmoji) \(item.statusText)"
            cellIdentifier = CellIdentifiers.StatusTextCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let selectedItem = tableView.selectedRowIndexes.first else {
            return
        }
        selectedProfileStatus = profileStatuses[selectedItem]
        selectedProfileIndex = selectedItem
        updateStatusFields()
    }

    func updateStatusFields() {
        statusTextTextField.stringValue = selectedProfileStatus.statusText
        statusEmojiUnicodeTextField.stringValue = String(format: "%X", selectedProfileStatus.emojiCode.unicodeScalars.first!.value)
        statusEmojiShortcodeTextField.stringValue = selectedProfileStatus.statusEmoji
        let displayEmoji = selectedProfileStatus.recognizedEmoji ? selectedProfileStatus.emojiCode : "\u{2753}"
        statusEmojiLabelTextField.stringValue = String(displayEmoji)
        if (profileStatuses.count > 1) {
            tableViewActionSegmentedControl.setEnabled(true, forSegment: 1)
        } else {
            tableViewActionSegmentedControl.setEnabled(false, forSegment: 1)
        }
    }
}

extension PreferencesViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        let newValue = textField.stringValue
        switch (textField.identifier!.rawValue) {
        case "StatusTextField":
            selectedProfileStatus.statusText = newValue
            break
        case "ShortcodeField":
            selectedProfileStatus.statusEmoji = newValue
            break
        case "UnicodeField":
            let nonHex = CharacterSet(charactersIn: "0123456789ABCDEFabcdef").inverted
            let nonHexRange = newValue.rangeOfCharacter(from: nonHex)
            let isHex: Bool! = nonHexRange == nil
            if (!isHex || newValue.count > 6) {
                textField.stringValue = String(format: "%X", selectedProfileStatus.emojiCode.unicodeScalars.first!.value)
                return
            }
            if (newValue == "") {
                return
            }

            let intValue = strtol(newValue, nil, 16)

            selectedProfileStatus.emojiCode = Character(UnicodeScalar(intValue)!)
            break
        default:
            break
        }
        tableView.reloadData(forRowIndexes: IndexSet([selectedProfileIndex]), columnIndexes: IndexSet([0]))
        updateStatusFields()
    }
}
