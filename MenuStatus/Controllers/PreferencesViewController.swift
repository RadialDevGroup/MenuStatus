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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
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
        NSLog("called")
        var text: String = ""
        var cellIdentifier: String = ""

        let item = profileStatuses[row]
        NSLog("\(item.statusText)")

        if tableColumn == tableView.tableColumns[0] {
            text = item.statusText
            cellIdentifier = CellIdentifiers.StatusTextCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
