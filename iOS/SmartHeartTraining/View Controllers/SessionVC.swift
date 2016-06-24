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
    
    @IBOutlet private weak var sendViaEmailButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var notesTextView: UITextView!
    @IBOutlet private weak var notesPlaceholderLabel: UILabel!
    
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
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        title = formatter.stringFromDate(session.dateStarted)
        
        notesTextView.text = session.notes
        notesPlaceholderLabel.hidden = !((session.notes ?? "").isEmpty)
        updateHeight(forTextView: notesTextView)
        
        accelerometerData = storageService.fetchAccelerometerData(sessionID: session.id)
        markers = storageService.fetchMarkers(sessionID: session.id)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startHandlingKeyboardEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopHandlingKeyboardEvents()
    }

    @IBAction func sendViaEmailButtonDidPress(sender: UIButton) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["es@madappgang.com"])
        mailComposerVC.setSubject("SmartHeartTraining data log")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss, d MMM yyyy"
        formatter.locale = NSLocale.currentLocale()
        let dateStartedString = formatter.stringFromDate(session.dateStarted) ?? ""
        
        var body = "Date captured:\n\(dateStartedString)"
        
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
        }
    }
    
    @IBAction func deleteButtonDidPress(sender: UIButton) {
        let confiramtionAlertController = UIAlertController(title: "Are you sure you want to delete session?", message: nil, preferredStyle: .Alert)
        confiramtionAlertController.view.tintColor = UIColor(red: 0.40, green: 0.80, blue: 1.00, alpha: 1.0)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        confiramtionAlertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            self.storageService.deleteSession(sessionID: self.session.id)
            self.performSegue(segueIdentifier: .unwindToSessionsVC)
        }
        confiramtionAlertController.addAction(deleteAction)
        
        presentViewController(confiramtionAlertController, animated: true, completion: nil)
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
        storageService.createOrUpdate(session)
    }
}

extension SessionVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
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
