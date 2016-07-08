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
        case toSessionVC
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptynessLabel: UILabel!

    var storageService: StorageService!
    var sessionsChangesService: SessionsChangesService!

    private var sessions: [[Session]] = []
    private var selectedSession: Session?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch(sessions: storageService.fetchSessions(), reloadTableView: false)
        
        sessionsChangesService.addObserver(self)
    }
    
    deinit {
        sessionsChangesService.removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .toOutputVC:
            guard let outputVC = segue.destinationViewController as? OutputVC else { return }
//            outputVC.loggingService = try! DependencyManager.resolve() as LoggingService
        case .toSessionVC:
            guard let sessionVC = segue.destinationViewController as? SessionVC else { return }
//            sessionVC.session = selectedSession
//            sessionVC.storageService = try! DependencyManager.resolve() as StorageService
//            sessionVC.dataToSendGenerationService = try! DependencyManager.resolve() as DataToSendGenerationService
        }
    }
    
    @IBAction func unwindToSessionsVC(sender: UIStoryboardSegue) {
        
    }

    private func fetch(sessions sessions: [Session], reloadTableView: Bool) {
        self.sessions = spreadOnSections(sessions)
        emptynessLabel.hidden = !(sessions.isEmpty)
        
        if reloadTableView {
            tableView.reloadData()
        }
    }
    
    private func spreadOnSections(sessions: [Session]) -> [[Session]] {
        guard !(sessions.isEmpty) else { return [] }
        
        var spreadedSessions: [[Session]] = []
        var sessionsSection: [Session] = []
        
        let unit: NSCalendarUnit = [.Day , .Month , .Year]
        for session in sessions.sortByDateStarted(.OrderedDescending) {
            if let previousSession = sessionsSection.last {
                let previousSessionDateComponents = NSCalendar.currentCalendar().components(unit, fromDate: previousSession.dateStarted)
                let sessionDateComponents = NSCalendar.currentCalendar().components(unit, fromDate: session.dateStarted)

                if previousSessionDateComponents != sessionDateComponents {
                    spreadedSessions.append(sessionsSection)
                    sessionsSection.removeAll()
                }
            }
            
            sessionsSection.append(session)
        }
        spreadedSessions.append(sessionsSection)

        return spreadedSessions
    }
}

extension SessionsVC: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sessions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueForIndexPath(indexPath) as SessionCell
        let session = sessions[indexPath.section][indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        cell.dateStartedLabel.text = formatter.stringFromDate(session.dateStarted)

        var durationLabelText: String?
        if let duration = session.duration {
            durationLabelText = NSDateComponentsFormatter.durationInMinutesAndSecondsFormatter.stringFromTimeInterval(duration)
        }
        cell.durationLabel.text = durationLabelText
        
        var samplesCountLabelText: String?
        if let samplesCount = session.samplesCount {
            samplesCountLabelText = "Samples: \(samplesCount)"
        }
        cell.samplesCountLabel.text = samplesCountLabelText

        var markersCountLabelText: String?
        if let markersCount = session.markersCount {
            markersCountLabelText = "Markers: \(markersCount)"
        }
        cell.markersCountLabel.text = markersCountLabelText
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if case .Delete = editingStyle {
            let sessionDataID = sessions[indexPath.section][indexPath.row].id
            storageService.deleteSession(sessionID: sessionDataID, completion: nil)
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

extension SessionsVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = DefaultHeaderView.loadFromNib()
        
        if let firstSessionData = sessions[section].first?.dateStarted {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            let dateString = formatter.stringFromDate(firstSessionData)
            
            headerView.titleLabel.text = dateString
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedSession = sessions[indexPath.section][indexPath.row]
        performSegue(segueIdentifier: .toSessionVC)
        selectedSession = nil
    }
}

extension SessionsVC: SessionsChangesObserver {
    
    func sessionsChangesMonitor(monitor: SessionsChangesMonitor, sessionsListDidChange sessions: [Session]) {
        fetch(sessions: sessions, reloadTableView: true)
    }
}

