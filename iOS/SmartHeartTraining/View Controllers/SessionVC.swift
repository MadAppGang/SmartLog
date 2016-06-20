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

    var session: SessionData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(session.id)"
    }

    @IBAction func sendViaEmailButtonDidPress(sender: UIButton) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
//        mailComposerVC.setToRecipients()
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