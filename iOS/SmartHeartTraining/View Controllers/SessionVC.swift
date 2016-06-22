//
//  SessionVC.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/18/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit
import MessageUI

final class SessionVC: UITableViewController {

    @IBOutlet private weak var sendViaEmailButton: UIButton!

    var storageService: StorageService!
    var dataToSendGenerationService: DataToSendGenerationService!
    
    var session: Session!
    
    private var accelerometerData: [AccelerometerData] = []
    private var markers: [Marker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(session.id)"
        
        accelerometerData = storageService.fetchAccelerometerData(sessionID: session.id)
        markers = storageService.fetchMarkers(sessionID: session.id)
    }

    @IBAction func sendViaEmailButtonDidPress(sender: UIButton) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["es@madappgang.com"])
        mailComposerVC.setSubject("SmartHeartTraining data log")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = NSLocale.currentLocale()
        let dateStartedString = formatter.stringFromDate(session.dateStarted) ?? ""
        let body = "Session ID: \(session.id)\nCaptured at: \(dateStartedString)"
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
}

extension SessionVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}