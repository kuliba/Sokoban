//
//  BiometricAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 16.02.2022.
//

import Foundation
import LocalAuthentication

class BiometricAgent: BiometricAgentProtocol {
    
    let reason: String
    
    init(reason: String = "Разблокировать при помощи сенсора") {
        
        self.reason = reason
    }
    
    var availableSensor: BiometricSensorType? {
        
        let context = LAContext()
        
        switch context.biometryType {
        case .faceID: return .face
        case .touchID: return .touch
        default: return nil
        }
    }
    
    func unlock(with sensor: BiometricSensorType, completion: @escaping (Result<Bool, BiometricAgentError>) -> Void) {

        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        // see demo project at:
        // https://developer.apple.com/documentation/localauthentication/logging_a_user_into_your_app_with_face_id_or_touch_id
        
        let context = LAContext()
        
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
        // Check if the user is able to use the policy we've selected previously
        var error: NSError? = nil
        guard context.canEvaluatePolicy(policy, error: &error) == true else {
            completion(.failure(.unableUsePolicy))
            return
        }
        
        if let error = error {
            completion(.failure(.failedCheckPolicyWithError(error)))
            return
        }
   
        context.evaluatePolicy(policy, localizedReason: reason, reply: { success, error in
 
            if let error = error {
                completion(.failure(.failedEvaluatePolicyWithError(error)))
                return
            }
            
            completion(.success(success))
        })
    }
}
