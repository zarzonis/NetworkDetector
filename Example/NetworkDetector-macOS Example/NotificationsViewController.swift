//
//  NotificationsViewController.swift
//  NetworkDetector_macOS_Example
//
//  Created by Spyridon Panagiotis Zarzonis on 09/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import NetworkDetector

class NotificationsViewController: NSViewController {
    
    @IBOutlet weak private var networkStatusTextField: NSTextField!
    
    var networkDetector: NetworkDetector!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        networkStatusTextField.isBezeled = false
        networkStatusTextField.isEditable = false
        
        networkDetector = NetworkDetector()
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: .networkStatusChanged, object: networkDetector)
        
        do {
            try networkDetector.startMonitoring()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    deinit {
        networkDetector.stopMonitoring()
    }
    
    @objc private func networkStatusChanged(_ note: Notification) {
        let networkDetector = note.object as! NetworkDetector
        
        switch networkDetector.connection {
        case .reachable:
            updateLabelForReachableInternetConnection()
        case .none:
            updateLabelForNoInternetConnection()
        }
    }
    
    private func updateLabelForReachableInternetConnection() {
        networkStatusTextField.textColor = .green
        networkStatusTextField.stringValue = "Internet connection is active"
    }
    
    private func updateLabelForNoInternetConnection() {
        networkStatusTextField.textColor = .red
        networkStatusTextField.stringValue = "Internet connection is down"
    }
}
