//
//  SessionsVC.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/15/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class SessionsVC: UIViewController, EnumerableSegueIdentifier {

    enum SegueIdentifier: String {
        case toOutputVC
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var storageService: StorageService!
    
    private var sessions: [SessionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessions = storageService.fetchSessionData().sort({ $0.dateStarted.compare($1.dateStarted) == .OrderedDescending })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .toOutputVC:
            guard let outputVC = segue.destinationViewController as? OutputVC else { return }
            outputVC.loggingService = try! DependencyManager.resolve() as LoggingService
        }
    }
    
    private func formatDateStarted(dateStarted: NSDate) -> String? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.stringFromDate(dateStarted)
    }
}

extension SessionsVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueForIndexPath(indexPath) as SessionCell
        let session = sessions[indexPath.row]
        
        cell.textLabel?.text = "\(session.id)"
        cell.detailTextLabel?.text = formatDateStarted(session.dateStarted)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if case .Delete = editingStyle {
            let sessionDataID = sessions[indexPath.row].id
            storageService.delete(sessionDataID)
            sessions.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

extension SessionsVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }
}