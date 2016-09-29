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
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var emptynessLabel: UILabel!

    var dependencyManager: DependencyManager!
    var storageService: StorageService!

    fileprivate var sessions: [[Session]] = []
    fileprivate var selectedSession: Session?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch(sessions: storageService.fetchSessions(), reloadTableView: false)
    }
    
    deinit {
        storageService.remove(changesObserver: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch identifier(for: segue) {
        case .toOutputVC:
            guard let outputVC = segue.destination as? OutputVC else { return }
            
            outputVC.loggingService = try! dependencyManager.resolve() as LoggingService
        case .toSessionVC:
            guard let sessionVC = segue.destination as? SessionVC else { return }
            
            sessionVC.session = selectedSession
            sessionVC.storageService = try! dependencyManager.resolve() as StorageService
            sessionVC.dataToSendGenerationService = try! dependencyManager.resolve() as DataToSendGenerationService
        }
    }
    
    @IBAction func unwindToSessionsVC(_ sender: UIStoryboardSegue) {
        
    }

    fileprivate func fetch(sessions: [Session], reloadTableView: Bool) {
        self.sessions = spreadOnSections(sessions)
        emptynessLabel.isHidden = !(sessions.isEmpty)
        
        if reloadTableView {
            tableView.reloadData()
        }
    }
    
    fileprivate func spreadOnSections(_ sessions: [Session]) -> [[Session]] {
        guard !(sessions.isEmpty) else { return [] }
        
        var spreadedSessions: [[Session]] = []
        var sessionsSection: [Session] = []
        
        let unit: NSCalendar.Unit = [.day , .month , .year]
        for session in sessions.sortByDateStarted(.orderedDescending) {
            if let previousSession = sessionsSection.last {
                let previousSessionDateComponents = (Calendar.current as NSCalendar).components(unit, from: previousSession.dateStarted)
                let sessionDateComponents = (Calendar.current as NSCalendar).components(unit, from: session.dateStarted)

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(at: indexPath) as SessionCell
        let session = sessions[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        cell.dateStartedLabel.text = formatter.string(from: session.dateStarted)

        let activityTypeString = session.activityType != .any ? " of \(session.activityType.string.lowercased())" : ""
        
        var durationLabelText = ""
        if let duration = session.duration, let durationString = DateComponentsFormatter.durationInMinutesAndSecondsFormatter.string(from: duration) {
            durationLabelText = durationString
        }
        cell.durationLabel.text = durationLabelText + activityTypeString
        
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
        
        cell.sentLabel.text = session.sent ? "(sent)" : ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            let sessionDataID = sessions[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].id
            storageService.deleteSession(sessionID: sessionDataID, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension SessionsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = DefaultHeaderView.loadFromNib()
        
        if let firstSessionData = sessions[section].first?.dateStarted {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            let dateString = formatter.string(from: firstSessionData as Date)
            
            headerView.titleLabel.text = dateString
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedSession = sessions[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        performSegue(.toSessionVC)
        selectedSession = nil
    }
}

extension SessionsVC: StorageChangesObserver {
    
    func storageService(_ storageService: StorageService, didChange session: Session, changeType: StorageChangeType) {
        fetch(sessions: storageService.fetchSessions(), reloadTableView: true)
    }
}

