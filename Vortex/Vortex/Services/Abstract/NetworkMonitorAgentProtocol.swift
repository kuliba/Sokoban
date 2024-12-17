//
//  NetworkMonitorAgentProtocol.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 26.01.2023.
//

import Foundation
import Combine

protocol NetworkMonitorAgentProtocol {
    
    var networkStatus: PassthroughSubject<NetworkAndInternetStatus, Never> { get }
    func checkInternet() 
}
