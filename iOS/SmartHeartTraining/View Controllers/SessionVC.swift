//
//  SessionVC.swift
//  SmartHeartTraining
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
    
    @IBOutlet private weak var sendViaEmailButton: UIBarButtonItem!
    
    @IBOutlet private weak var sessionChartView: SessionChartView!
    
    @IBOutlet private weak var startedAtLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var numberOfSamplesLabel: UILabel!
    @IBOutlet private weak var numberOfMarkersLabel: UILabel!
    @IBOutlet private weak var activityTypeLabel: UILabel!
    @IBOutlet private weak var sentLabel: UILabel!
    
    @IBOutlet private weak var notesTextView: UITextView!
    @IBOutlet private weak var notesPlaceholderLabel: UILabel!

    @IBOutlet private weak var deleteButton: UIButton!
    
    var storageService: StorageService!
    var dataToSendGenerationService: DataToSendGenerationService!
    
    var session: Session!
    
    private let defaultNotesCellHeight: CGFloat = 112
    
    private var accelerometerData: [AccelerometerData] = []
    private var markers: [Marker] = []
    
    private var tableTopInset: CGFloat = 0
    
    private var notesCellHeight: CGFloat = 112
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendViaEmailButton.enabled = false
        
        storageService.add(changesObserver: self)
        
        fetch(session: session)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startHandlingKeyboardEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopHandlingKeyboardEvents()
        
    }
    
    deinit {
        storageService.remove(changesObserver: self)
    }

    @IBAction func sendViaEmailButtonDidPress(sender: UIBarButtonItem) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["es@madappgang.com"])
        mailComposerVC.setSubject("SmartHeartTraining data log")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        formatter.locale = NSLocale.currentLocale()
        let dateStartedString = formatter.stringFromDate(session.dateStarted) ?? ""
        
        var body = "Date captured: \(dateStartedString)"
        body.appendContentsOf("\nSamples count: \(session.samplesCountValue)")
        body.appendContentsOf("\nMarkers count: \(session.markersCountValue)")
        body.appendContentsOf("\nActivity type: \(session.activityType.string)")
        
        if let notes = session.notes {
            body.appendContentsOf("\n\nNotes:\n\(notes)")
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
            presentViewController(mailComposerVC, animated: true, completion: nil)
            mailComposerVC.view.tintColor = UIColor.darkGrayColor()
        }
    }
    
    @IBAction func deleteButtonDidPress(sender: UIButton) {
        let confiramtionAlertController = UIAlertController(title: "Are you sure you want to delete session?", message: nil, preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        confiramtionAlertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            self.storageService.deleteSession(sessionID: self.session.id, completion: nil)
            self.performSegue(segueIdentifier: .unwindToSessionsVC)
        }
        confiramtionAlertController.addAction(deleteAction)
        
        presentViewController(confiramtionAlertController, animated: true, completion: nil)
        confiramtionAlertController.view.tintColor = UIColor.darkGrayColor()
    }
    
    private func fetch(session session: Session) {
        self.session = session
        
        fetchInfoSection(session: session)
        fetchNotesSection(session: session)
        
        sessionData { [weak self] accelerometerData, markers in
            guard let weakSelf = self else { return }
            
            weakSelf.accelerometerData = accelerometerData
            weakSelf.markers = markers
            
            weakSelf.sessionChartView.set(accelerometerData: accelerometerData, markers: markers)
            
            weakSelf.sendViaEmailButton.enabled = accelerometerData.count > 0
        }
    }
    
    private func fetchInfoSection(session session: Session) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        formatter.locale = NSLocale.currentLocale()
        startedAtLabel.text = formatter.stringFromDate(session.dateStarted)
        
        durationLabel.text = NSDateComponentsFormatter.durationInMinutesAndSecondsFormatter.stringFromTimeInterval(session.durationValue)
        
        numberOfSamplesLabel.text = "\(session.samplesCountValue)"
        numberOfMarkersLabel.text = "\(session.markersCountValue)"
        activityTypeLabel.text = session.activityType.string
        sentLabel.text = session.sent ? "Yes" : "No"
    }
    
    private func fetchNotesSection(session session: Session) {
        notesTextView.text = session.notes
        notesPlaceholderLabel.hidden = !((session.notes ?? "").isEmpty)
        updateHeight(forTextView: notesTextView)
    }
    
    private func sessionData(completion: (accelerometerData: [AccelerometerData], markers: [Marker]) -> ()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            guard let weakSelf = self else { return }
            
            let accelerometerData = weakSelf.storageService.fetchAccelerometerData(sessionID: weakSelf.session.id)
            let markers = weakSelf.storageService.fetchMarkers(sessionID: weakSelf.session.id)
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(accelerometerData: accelerometerData, markers: markers)
            }
        }
    }
    
    private func updateHeight(forTextView textView: UITextView) {
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
}

// MARK: - UITableViewDelegate

extension SessionVC {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return notesCellHeight
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}

extension SessionVC: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        updateHeight(forTextView: textView)
        
        session.notes = textView.text
        notesPlaceholderLabel.hidden = !(textView.text.isEmpty)
        storageService.createOrUpdate(session, completion: nil)
    }
}

extension SessionVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultSaved, MFMailComposeResultSent where !session.sent:
            session.sent = true
            storageService.createOrUpdate(session, completion: nil)
            
            fetchInfoSection(session: session)
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SessionVC: KeyboardEventsHandler {
    
    func keyboardWillShowWithRect(keyboardRect: CGRect, animationDuration: NSTimeInterval) {
        tableTopInset = tableView.contentInset.top
        let insets = UIEdgeInsets(top: tableTopInset, left: 0, bottom: keyboardRect.size.height, right: 0)
        
        tableView.scrollIndicatorInsets = insets
    }
    
    func keyboardWillHideFromRect(keyboardRect: CGRect, animationDuration: NSTimeInterval) {
        let insets = UIEdgeInsets(top: tableTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.scrollIndicatorInsets = insets
    }
}

extension SessionVC: StorageChangesObserver {
    
    func storageService(storageService: StorageService, didChange session: Session, changeType: StorageChangeType) {
        if session.samplesCountValue != self.session.samplesCountValue
            || session.markersCountValue != self.session.markersCountValue {
            fetch(session: session)
        }
    }
}
