//
//  ViewController.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 5/27/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    private let pebbleManager = PebbleManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pebbleManager.delegate = self
    }

    @IBAction func clearButtonDidPress(sender: UIBarButtonItem) {
        textView.text = ""
    }

}

extension ViewController: PebbleManagerDelegate {
    
    func handleOutputStirng(string: String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        textView.text = "\(textView.text)\n\(formatter.stringFromDate(NSDate())): \(string)"
    }
}
