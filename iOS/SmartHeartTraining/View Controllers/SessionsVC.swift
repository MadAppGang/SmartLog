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
    
    private var sessions: [SessionData] = [SessionData(id: 1466000000, dateStarted: NSDate()), SessionData(id: 1466000000, dateStarted: NSDate()), SessionData(id: 1466000000, dateStarted: NSDate())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
}