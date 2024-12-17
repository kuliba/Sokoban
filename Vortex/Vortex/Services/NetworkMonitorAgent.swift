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

    let networkStatus: PassthroughSubject<NetworkAndInternetStatus, Never> = .init()
    
    private var pathMonitor: NWPathMonitor
    
    private lazy var pathUpdateHandler: ((NWPath) -> Void) = { [weak self] path in
    
        switch path.status {
        case .satisfied:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.satisfied")
            self?.networkStatus.send(.networkEnabled)
            
        case .unsatisfied:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.unsatisfied")
            self?.networkStatus.send(.noNetwork)
        
        case .requiresConnection:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.requiresConnection")
            self?.networkStatus.send(.noNetwork)
            
        @unknown default:
            LoggerAgent.shared.log(level: .info,
                                   category: .network,
                                   message: "NWPath.Status.Unknown")
            self?.networkStatus.send(.noNetwork)
        }
    }

    private let backgroudQueue = DispatchQueue.global(qos: .background)
    private var urlSession: URLSession

    init() {
        
        self.urlSession = {
            let newConfiguration: URLSessionConfiguration = .default
            newConfiguration.waitsForConnectivity = false
            newConfiguration.allowsCellularAccess = true
            return URLSession(configuration: newConfiguration)
        }()
        
        self.pathMonitor = NWPathMonitor()
        self.pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        self.pathMonitor.start(queue: backgroudQueue)
    }
    
    public func checkInternet() {

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

        self.networkStatus.send(success ? .internetEnabled : .noNetwork)
    }

}

enum NetworkAndInternetStatus {
    case noNetwork
    case networkEnabled
    case internetEnabled
    
    var isConnect: Bool {
        
        switch self {
        case .networkEnabled, .internetEnabled: return true
        case .noNetwork: return false
        }
    }
}
    
