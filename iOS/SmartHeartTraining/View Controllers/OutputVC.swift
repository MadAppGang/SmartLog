//
//  OutputVC.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 5/27/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class OutputVC: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func clearButtonDidPress(sender: UIBarButtonItem) {
        
    }

    @IBAction func pingButtonDidPress(sender: UIBarButtonItem) {
        
    }
}

//extension OutputVC: PebbleManagerDelegate {
//    
//    func handleOutputString(string: String) {
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "HH:mm:ss.SSS"
//        
//        textView.text = "\(textView.text)\n\(formatter.stringFromDate(NSDate())): \(string)"
//        
//        let range = NSRange(location: textView.text.characters.count, length: 1)
//        textView.scrollRangeToVisible(range)
//    }
//}
