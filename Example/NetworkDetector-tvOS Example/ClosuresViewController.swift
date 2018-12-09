//
//  ClosuresViewController.swift
//  NetworkDetector_tvOS_Example
//
//  Created by Spyridon Panagiotis Zarzonis on 09/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NetworkDetector

class ClosuresViewController: UIViewController {
    
    @IBOutlet weak private var networkStatusLabel: UILabel!
    
    var networkDetector: NetworkDetector!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        networkStatusLabel.textColor = .green
        networkStatusLabel.text = "Internet connection is active"
    }
    
    private func updateLabelForNoInternetConnection() {
        networkStatusLabel.textColor = .red
        networkStatusLabel.text = "Internet connection is down"
    }
}
