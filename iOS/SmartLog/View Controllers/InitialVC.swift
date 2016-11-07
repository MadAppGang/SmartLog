//
//  InitialVC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class InitialVC: UIViewController, EnumerableSegueIdentifier {
    
    enum SegueIdentifier: String {
        case toHomeTBC
    }
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private let dependencyManager = DependencyManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dependencyManager.setup(
            progressHandler: { progress in
                self.progressView.isHidden = !(progress > 0)
                self.progressView.setProgress(progress, animated: true)
            },
            completion: { result in
                switch result {
                case .successful:
                    self.performSegue(.toHomeTBC)
                case .failed(let error):
                    self.messageLabel.text = "\(error)"
                }
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch identifier(for: segue) {
        case .toHomeTBC:
            guard let homeTBC = segue.destination as? HomeTBC else { return }
            
            homeTBC.dependencyManager = dependencyManager
        }
    }
    
}
