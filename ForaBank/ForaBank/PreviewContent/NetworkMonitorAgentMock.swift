//
//  NetworkMonitorAgentMock.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 27.01.2023.
//

import Foundation
import Combine

class NetworkMonitorAgentMock: NetworkMonitorAgentProtocol {
    func checkInternet() {}
    
    var networkStatus: PassthroughSubject<NetworkAndInternetStatus, Never> = .init()
    
}
