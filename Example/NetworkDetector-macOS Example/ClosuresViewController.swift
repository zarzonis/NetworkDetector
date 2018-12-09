//
//  ClosuresViewController.swift
//  NetworkDetector-macOS Example
//
//  Created by Spyridon Panagiotis Zarzonis on 09/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import NetworkDetector

class ClosuresViewController: NSViewController {
    
    @IBOutlet weak private var networkStatusTextField: NSTextField!
    
    var networkDetector: NetworkDetector!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        networkStatusTextField.isBezeled = false
        networkStatusTextField.isEditable = false
        
        networkDetector = NetworkDetector()
        
        networkDetector.reachableHandler = { [weak self] in
            self?.updateLabelForReachableInternetConnection()
        }
        
        networkDetector.unreachableHandler = { [weak self] in
            self?.updateLabelForNoInternetConnection()
        }
        
        do {
            try networkDetector.startMonitoring()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    deinit {
        networkDetector.stopMonitoring()
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

