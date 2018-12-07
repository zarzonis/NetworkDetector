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
   
    private var monitor: NWPathMonitor?
    private var queue: DispatchQueue
    // The notification center on which "networkStatusChanged" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default
    
    private var isMonitorRunning = false
    
    //Get the current network status. If the monitor did not start monitoring, the value of this property is nil.
    private var currentNetworkStatus: NWPath.Status?
    
    //The handlers that will be called on network status change
    public var reachableHandler: ReachableHandler?
    public var unreachableHandler: UnreachableHandler?
    
    public var connection: Connection? {
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
        monitor?.pathUpdateHandler = { [unowned self] path in
        
            let newNetworkStatus = path.status
            
            if self.currentNetworkStatus == nil {
                self.currentNetworkStatus = newNetworkStatus
                return
            }
            //The pathUpdateHandler of the NWPathMonitor can be called multiple times for the same newtork status
            //change, so we need to find out if the new network status is different that the current status.
            guard self.currentNetworkStatus != newNetworkStatus else { return }
            
            self.currentNetworkStatus = newNetworkStatus
            self.runAppropriateHandlerForCurrentNetworkStatus()
        }
    }
    
    //MARK: - Public methods
    public func startMonitoring() throws {
        guard let monitor = monitor else { throw NetworkDetectorError.InvalidNetworkDetector}
        guard !isMonitorRunning else { return }
        currentNetworkStatus = NWPath.Status.satisfied
        monitor.start(queue: queue)
        isMonitorRunning = true
    }
    
    public func stopMonitoring() {
        //Check if there is a monitor to stop and that it's not already stopped.
        guard let monitor = monitor, isMonitorRunning else { return }
        monitor.cancel()
        
        //Invalidate monitor
        invalidateMonitor()
        isMonitorRunning = false
    }
    
    //MARK: - Private methods
    
    //This method runs the reachableHandler or the unreachableHandler based on the current network status,
    //or does nothing in case the network monitor did not yet started monitoring.
    private func runAppropriateHandlerForCurrentNetworkStatus() {
        let handler = connection != .none ? reachableHandler : unreachableHandler
        
        DispatchQueue.main.async {
            handler?()
        }
    }
    
    //Monitor can't be started again if stopped, so we need to set it to nil in order to avoid further usage
    private func invalidateMonitor() {
        monitor = nil
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
