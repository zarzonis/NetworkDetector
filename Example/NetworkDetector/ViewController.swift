//
//  ViewController.swift
//  NetworkDetector
//
//  Created by Spyros Zarzonis on 12/04/2018.
//  Copyright (c) 2018 Spyros Zarzonis. All rights reserved.
//

import UIKit
import NetworkDetector

class ViewController: UIViewController {
    
    @IBOutlet weak private var networkStatusLabel: UILabel!
    
    var networkDetector: NetworkDetector!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        networkDetector = NetworkDetector()
        
        networkDetector.reachableHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.networkStatusLabel.textColor = .green
                self?.networkStatusLabel.text = "Internet connection is active"
            }
            
        }
        
        networkDetector.unreachableHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.networkStatusLabel.textColor = .red
                self?.networkStatusLabel.text = "Internet connection is down"
            }
        }
        
        do {
           try networkDetector.startMonitoring()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

