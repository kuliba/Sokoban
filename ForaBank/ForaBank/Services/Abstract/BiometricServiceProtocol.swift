//
//  BiometricServiceProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 16.02.2022.
//

import Foundation

protocol BiometricServiceProtocol {
    
    var availableSensor: BiometricSensorType? { get }
    func unlock(with sensor: BiometricSensorType, completion: @escaping (Result<Bool, BiometricServiceError>) -> Void)
}

enum BiometricServiceError: Error {

    case unableUsePolicy
    case failedCheckPolicyWithError(Error)
    case failedEvaluatePolicyWithError(Error)
}
