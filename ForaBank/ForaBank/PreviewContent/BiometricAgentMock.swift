//
//  BiometricAgentMock.swift
//  ForaBank
//
//  Created by Max Gribov on 01.03.2022.
//

import Foundation

class BiometricAgentMock: BiometricAgentProtocol {

    var availableSensor: BiometricSensorType? { .touch }
    
    func unlock(with sensor: BiometricSensorType, completion: @escaping (Result<Bool, BiometricAgentError>) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            
            completion(.success(true))
        }
    }
}
