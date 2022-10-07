//
//  BiometricAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 16.02.2022.
//

import Foundation

protocol BiometricAgentProtocol {
    
    var availableSensor: BiometricSensorType? { get }
    func unlock(with sensor: BiometricSensorType, completion: @escaping (Result<Bool, BiometricAgentError>) -> Void)
}

enum BiometricAgentError: Error {

    case unableUsePolicy(Error?)
    case failedEvaluatePolicyWithError(Error)
}
