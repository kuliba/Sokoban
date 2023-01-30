//
//  NetworkMonitorAgent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 26.01.2023.
//

import Foundation
import Combine
import Network

class NetworkMonitorAgent: NetworkMonitorAgentProtocol {

    let isNetworkAvailable: PassthroughSubject<Bool, Never> = .init()
    
    private var pathMonitor: NWPathMonitor
    
    private lazy var pathUpdateHandler: ((NWPath) -> Void) = { [weak self] path in
    
        switch path.status {
        case .satisfied:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.satisfied")
            self?.isNetworkAvailable.send(true)
            
        case .unsatisfied:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.unsatisfied")
            self?.isNetworkAvailable.send(false)
        
        case .requiresConnection:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.requiresConnection")
            self?.isNetworkAvailable.send(false)
            
        @unknown default:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.Unknown")
            self?.isNetworkAvailable.send(false)
        }
    }

    private let backgroudQueue = DispatchQueue.global(qos: .background)
    
    private var urlSession: URLSession = {
        var newConfiguration: URLSessionConfiguration = .default
        newConfiguration.waitsForConnectivity = false
        newConfiguration.allowsCellularAccess = true
        return URLSession(configuration: newConfiguration)
    }()

    public func isGoogleAvailable() -> Bool
    {
        let url = URL(string: "https://8.8.8.8")!
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let task = urlSession.dataTask(with: url)
            { data, response, error in
                if error != nil { success = false }
                else { success = true }
                semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return success
    }
    

    init() {
        self.pathMonitor = NWPathMonitor()
        self.pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        self.pathMonitor.start(queue: backgroudQueue)
    }

}
    
