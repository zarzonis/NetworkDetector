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
    
    enum NetworkStatus: CustomStringConvertible {
        case reachable
        case unreachable
        
        //Creates a NetworkStatus from a NWPath.Status
        fileprivate static func status(from pathStatus: NWPath.Status) -> NetworkStatus {
            if pathStatus == .satisfied {
                return .reachable
            } else {
                return .unreachable
            }
        }
        
        var description: String {
            switch self {
            case .reachable:
                return "Reachable"
            case .unreachable:
                return "Unreachable"
            }
        }
    }
    
    public typealias ReachableHandler = (() -> Void)
    public typealias UnreachableHandler = (() -> Void)
   
    private var monitor: NWPathMonitor?
    private var queue: DispatchQueue
    
    //A lock that is used to evaluate the new network status atomically.
    private let lock = NSLock()
    
    private var isMonitorRunning = false
    
    //Get the current network status. If the monitor did not start monitoring, the value of this property is nil.
    private var currentNetworkStatus: NetworkStatus?
    
    //The handlers that will be called on network status change
    public var reachableHandler: ReachableHandler?
    public var unreachableHandler: UnreachableHandler?
    
    public init(targetQueue: DispatchQueue? = nil ) {
        queue = DispatchQueue(label: "com.zarzonis.NetworkMonitor", qos: .default, target: targetQueue)
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [unowned self] path in
            defer {
                self.lock.unlock()
            }
            self.lock.lock()
            
            
            let newNetworkStatus = NetworkStatus.status(from: path.status)
            //The pathUpdateHandler of the NWPathMonitor can be called multiple times for the same newtork status
            //change, so we need to find out if the new network status is different that the current status.
            guard self.currentNetworkStatus != newNetworkStatus else { return }
            
            self.currentNetworkStatus = newNetworkStatus
            self.runAppropriateHandlerForCurrentNetworkStatus()
        }
    }
    
    //MARK: - Public methods
    func startMonitoring() throws {
        guard let monitor = monitor else { throw NetworkDetectorError.InvalidNetworkDetector}
        guard !isMonitorRunning else { return }
        currentNetworkStatus = .reachable
        monitor.start(queue: queue)
        isMonitorRunning = true
    }
    
    func stopMonitoring() {
        //Check if there is a monitor to stop and that it's not already stopped.
        guard let monitor = monitor, isMonitorRunning else { return }
        monitor.cancel()
        
        //Invalidate monitor
        invalidateMonitor()
        isMonitorRunning = false
    }
    
    //This method returns true or false based on whether the network is reachable or not and nil if
    //the network detector has not started monitoring yet.
    func isNetworkReachable() -> Bool? {
        guard let currentNetworkStatus = currentNetworkStatus else { return nil }
        return currentNetworkStatus == .reachable
    }
    
    //MARK: - Private methods
    
    //This method runs the reachableHandler or the unreachableHandler based on the current network status,
    //or does nothing in case the network monitor did not yet started monitoring.
    private func runAppropriateHandlerForCurrentNetworkStatus() {
        guard let currentStatus = currentNetworkStatus else { return }
        switch currentStatus {
        case .reachable:
            reachableHandler?()
        case .unreachable:
            unreachableHandler?()
        }
    }
    
    //Monitor can't be started again if stopped, so we need to set it to nil in order to avoid further usage
    private func invalidateMonitor() {
        monitor = nil
    }
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
