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
    
    var networkDetector: NetworkDetector!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        networkDetector = NetworkDetector()
        
        networkDetector.reachableHandler = {
            print("Internet connection is active")
        }
        
        networkDetector.unreachableHandler = {
            print("Internet connection is down")
        }
        
        do {
           try networkDetector.startMonitoring()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

