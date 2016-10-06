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
    
    var loggingService: LoggingService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        loggingService.delegate = self
        
        set(logString: loggingService.logString)
    }

    @IBAction func clearButtonDidPress(_ sender: UIBarButtonItem) {
        loggingService.clear()
    }
    
    fileprivate func set(logString: String) {
        textView.text = logString
        
        let range = NSRange(location: textView.text.characters.count, length: 1)
        textView.scrollRangeToVisible(range)
    }
}

extension OutputVC: LoggingServiceDelegate {
    
    func logDidChange(_ logString: String) {
        set(logString: logString)
    }
}
