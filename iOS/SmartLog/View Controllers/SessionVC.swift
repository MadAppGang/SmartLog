//
//  SessionVC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/18/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit
import MessageUI

final class SessionVC: UITableViewController, EnumerableSegueIdentifier {

    enum SegueIdentifier: String {
        case unwindToSessionsVC
    }
    
    @IBOutlet fileprivate weak var notesPlaceholderLabel: UILabel!
    
    @IBOutlet private weak var sendViaEmailButton: UIBarButtonItem!
    
    @IBOutlet private weak var sessionChartView: SessionChartView!
    
    @IBOutlet private weak var startedAtLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var numberOfSamplesLabel: UILabel!
    @IBOutlet private weak var numberOfMarkersLabel: UILabel!
    @IBOutlet private weak var activityTypeLabel: UILabel!
    @IBOutlet private weak var sentLabel: UILabel!
    
    @IBOutlet private weak var notesTextView: UITextView!

    @IBOutlet private weak var deleteButton: UIButton!
    
    var storageService: StorageService!
    var dataToSendGenerationService: DataToSendGenerationService!
    
    var session: Session!
    
    fileprivate var tableTopInset: CGFloat = 0
    fileprivate var notesCellHeight: CGFloat = 112

    private let defaultNotesCellHeight: CGFloat = 112
    
    private var accelerometerData: [AccelerometerData] = []
    private var markers: [Marker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendViaEmailButton.isEnabled = false
        
        storageService.add(changesObserver: self)
        
        fetch(session: session)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startKeyboardEventsHandling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopKeyboardEventsHandling()
    }
    
    deinit {
        storageService.remove(changesObserver: self)
    }

    @IBAction func sendViaEmailButtonDidPress(_ sender: UIBarButtonItem) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["es@madappgang.com"])
        mailComposerVC.setSubject("SmartLog data log")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        formatter.locale = .current
        let dateStartedString = formatter.string(from: session.dateStarted as Date)
        
        var body = "Date captured: \(dateStartedString)"
        body.append("\nSamples count: \(session.samplesCountValue)")
        body.append("\nMarkers count: \(session.markersCountValue)")
        body.append("\nActivity type: \(session.activityType.string)")
        
        if let notes = session.notes {
            body.append("\n\nNotes:\n\(notes)")
        }
        
        mailComposerVC.setMessageBody(body, isHTML: false)
        
        let mimeType = "text/plain"
        
        if let accelerometerDataToSend = try? dataToSendGenerationService.convertToData(accelerometerData) {
            let accelerometerDataFileName = "accel_\(session.id).txt"
            mailComposerVC.addAttachmentData(accelerometerDataToSend, mimeType: mimeType, fileName: accelerometerDataFileName)
        }

        if let markersToSend = try? dataToSendGenerationService.convertToData(markers) {
            let markersDataFileName = "markers_\(session.id).txt"
            mailComposerVC.addAttachmentData(markersToSend, mimeType: mimeType, fileName: markersDataFileName)
        }
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposerVC, animated: true, completion: nil)
            mailComposerVC.view.tintColor = .darkGray
        }
    }
    
    @IBAction func deleteButtonDidPress(_ sender: UIButton) {
        let confiramtionAlertController = UIAlertController(title: "Are you sure you want to delete session?", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        confiramtionAlertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.storageService.deleteSession(sessionID: self.session.id, completion: nil)
            self.performSegue(.unwindToSessionsVC)
        }
        confiramtionAlertController.addAction(deleteAction)
        
        present(confiramtionAlertController, animated: true, completion: nil)
        confiramtionAlertController.view.tintColor = .darkGray
    }
    
    fileprivate func updateHeight(forTextView textView: UITextView) {
        let textHorizontalMargins: CGFloat = 10
        let textVerticalMargins: CGFloat = 18
        
        let width = textView.bounds.width - textHorizontalMargins
        let height = textView.text.height(width: width, font: textView.font!) + textVerticalMargins
        
        let newNotesCellHeight = height > defaultNotesCellHeight ? height : defaultNotesCellHeight
        
        if newNotesCellHeight != notesCellHeight {
            notesCellHeight = newNotesCellHeight
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    fileprivate func fetch(session: Session) {
        self.session = session
        
        fetchInfoSection(session: session)
        fetchNotesSection(session: session)
        
        sessionData { [weak self] accelerometerData, markers in
            guard let weakSelf = self else { return }
            
            weakSelf.accelerometerData = accelerometerData
            weakSelf.markers = markers
            
            weakSelf.sessionChartView.set(accelerometerData: accelerometerData, markers: markers)
            
            weakSelf.sendViaEmailButton.isEnabled = accelerometerData.count > 0
        }
    }
    
    fileprivate func fetchInfoSection(session: Session) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        formatter.locale = .current
        startedAtLabel.text = formatter.string(from: session.dateStarted)
        
        durationLabel.text = DateComponentsFormatter.durationInMinutesAndSecondsFormatter.string(from: session.durationValue)
        
        numberOfSamplesLabel.text = "\(session.samplesCountValue)"
        numberOfMarkersLabel.text = "\(session.markersCountValue)"
        activityTypeLabel.text = session.activityType.string
        sentLabel.text = session.sent ? "Yes" : "No"
    }
    
    private func fetchNotesSection(session: Session) {
        notesTextView.text = session.notes
        notesPlaceholderLabel.isHidden = !((session.notes ?? "").isEmpty)
        updateHeight(forTextView: notesTextView)
    }
    
    private func sessionData(_ completion: @escaping (_ accelerometerData: [AccelerometerData], _ markers: [Marker]) -> Void) {
        let userInitiatedQueue: DispatchQueue = .global(qos: .userInitiated)
        userInitiatedQueue.async { [weak self] in
            guard let weakSelf = self else { return }
            
            weakSelf.storageService.fetchAccelerometerData(sessionID: weakSelf.session.id, completionQueue: userInitiatedQueue) { accelerometerData in
                weakSelf.storageService.fetchMarkers(sessionID: weakSelf.session.id, completionQueue: .main) { markers in
                    completion(accelerometerData, markers)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension SessionVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return notesCellHeight
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

extension SessionVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateHeight(forTextView: textView)
        
        session.notes = textView.text
        notesPlaceholderLabel.isHidden = !(textView.text.isEmpty)
        storageService.createOrUpdate(session, completion: nil)
    }
}

extension SessionVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .saved,
             .sent where !session.sent:
            session.sent = true
            storageService.createOrUpdate(session, completion: nil)
            
            fetchInfoSection(session: session)
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SessionVC: KeyboardEventsHandler {
    
    func keyboardWillShow(in rect: CGRect, animationDuration: TimeInterval) {
        tableTopInset = tableView.contentInset.top
        let insets = UIEdgeInsets(top: tableTopInset, left: 0, bottom: rect.size.height, right: 0)
        
        tableView.scrollIndicatorInsets = insets
    }
    
    func keyboardWillHide(from rect: CGRect, animationDuration: TimeInterval) {
        let insets = UIEdgeInsets(top: tableTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.scrollIndicatorInsets = insets
    }
}

extension SessionVC: StorageChangesObserver {
    
    func storageService(_ storageService: StorageService, didChange session: Session, changeType: StorageChangeType) {
        if session.samplesCountValue != self.session.samplesCountValue
            || session.markersCountValue != self.session.markersCountValue {
            fetch(session: session)
        }
    }
}
