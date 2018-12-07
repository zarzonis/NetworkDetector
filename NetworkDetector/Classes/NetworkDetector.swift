//
//  NetworkDetector.swift
//  NetworkConnection
//
//  Created by Spyridon Panagiotis Zarzonis on 04/12/2018.
//  Copyright © 2018 Spyridon Panagiotis Zarzonis. All rights reserved.
//

import Foundation
import Network

@available(iOS 12.0, *) public class NetworkDetector {
    
    public enum Connection: CustomStringConvertible {
        case none
        case reachable
        
        public var description: String {
            switch self {
            case .none:
                return "No Connection"
            case .reachable:
                return "Active Connection"
            }
        }
    }
    
    public typealias ReachableHandler = (() -> Void)
    public typealias UnreachableHandler = (() -> Void)
   
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    // The notification center on which "networkStatusChanged" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default
    
    private var isMonitorRunning = false
    
    //Get the current network status. If the monitor did not start monitoring, the value of this property is nil.
    private var currentNetworkStatus: NWPath.Status?
    
    //The handlers that will be called on network status change
    public var reachableHandler: ReachableHandler?
    public var unreachableHandler: UnreachableHandler?
    
    public var connection: Connection {
        switch currentNetworkStatus {
        case .satisfied?:
            return .reachable
        default:
            return .none
        }
    }
    
    public init(targetQueue: DispatchQueue? = nil ) {
        queue = DispatchQueue(label: "com.zarzonis.NetworkMonitor", qos: .default, target: targetQueue)
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [unowned self] path in
            let newNetworkStatus = path.status
            
            //Set the initial network status without calling networkStatusChanged()
            if self.currentNetworkStatus == nil {
                self.currentNetworkStatus = newNetworkStatus
                return
            }
            
            //Save the new network status and call networkStatusChanged() only if it's different that the
            //current network status
            guard self.currentNetworkStatus != newNetworkStatus else { return }
            
            self.currentNetworkStatus = newNetworkStatus
            self.networkStatusChanged()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    //MARK: - Public methods
    public func startMonitoring() throws {
        guard !isMonitorRunning else { return }
        monitor.start(queue: queue)
        isMonitorRunning = true
    }
    
    public func stopMonitoring() {
        //Check if the monitor it's not already stopped.
        guard isMonitorRunning else { return }
        monitor.cancel()
        isMonitorRunning = false
    }
    
    //MARK: - Private methods
    
    //This method runs the reachableHandler or the unreachableHandler based on the current network status,
    //if the network status is set. Otherwise it does nothing.
    private func networkStatusChanged() {
        
        guard let currentNetworkStatus = currentNetworkStatus else { return }
        
        let handler = currentNetworkStatus == .satisfied ? reachableHandler : unreachableHandler
        
        DispatchQueue.main.async { [weak self] in
            handler?()
            self?.notificationCenter.post(name: .networkStatusChanged, object: self)
        }
    }
}

public extension Notification.Name {
    public static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

@available(iOS 12.0, *) public enum NetworkDetectorError: Error, LocalizedError {
    //If you receive this error, this means that the NetworkMonitor has been stopped and you need
    //to create a new instance.
    case InvalidNetworkDetector
    
    public var errorDescription: String? {
        switch self {
        case .InvalidNetworkDetector:
            return "The network detector is invalid."
        }
    }
}
