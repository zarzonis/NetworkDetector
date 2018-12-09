//
//  NotificationsViewController.swift
//  NetworkDetector_tvOS_Example
//
//  Created by Spyridon Panagiotis Zarzonis on 09/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NetworkDetector

class NotificationsViewController: UIViewController {

    @IBOutlet weak private var networkStatusLabel: UILabel!
    
    var networkDetector: NetworkDetector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        networkStatusLabel.textColor = .green
        networkStatusLabel.text = "Internet connection is active"
    }
    
    private func updateLabelForNoInternetConnection() {
        networkStatusLabel.textColor = .red
        networkStatusLabel.text = "Internet connection is down"
    }
}
