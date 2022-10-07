//
//  BiometricSensorType.swift
//  ForaBank
//
//  Created by Max Gribov on 16.02.2022.
//

import Foundation
import LocalAuthentication
import SwiftUI

enum BiometricSensorType {
    
    case face
    case touch
}

extension BiometricSensorType {
    
    init?(with type: LABiometryType) {
        
        switch type {
        case .faceID: self = .face
        case .touchID: self = .touch
        default: return nil
        }
    }
    
    var type: LABiometryType {
        
        switch self {
        case .face: return .faceID
        case .touch: return .touchID
        }
    }
}

extension BiometricSensorType {
    
    var icon: Image {
        
        switch self {
        case .face: return .ic40FaceId
        case .touch: return .ic40TouchID
        }
    }
}

extension BiometricSensorType: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        switch self {
        case .face: return "Face ID"
        case .touch: return "Touch ID"
        }
    }
}
