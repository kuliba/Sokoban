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
    
      if path.status == .satisfied {
          LoggerAgent.shared.log(level: .info,
                                 category: .network,
                                 message: "NWPath.Status.satisfied")
          self?.isNetworkAvailable.send(true)
          
      } else if path.status == .unsatisfied {
          LoggerAgent.shared.log(level: .info,
                                 category: .network,
                                 message: "NWPath.Status.unsatisfied")
          self?.isNetworkAvailable.send(false)
          
      } else if path.status == .requiresConnection {
          LoggerAgent.shared.log(level: .info,
                                 category: .network,
                                 message: "NWPath.Status.requiresConnection")
          self?.isNetworkAvailable.send(false)
      }
    }

    private let backgroudQueue = DispatchQueue.global(qos: .background)

    init() {
        self.pathMonitor = NWPathMonitor()
        self.pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        self.pathMonitor.start(queue: backgroudQueue)
    }

}
    
