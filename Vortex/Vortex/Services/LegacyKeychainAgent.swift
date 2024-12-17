//
//  LegacyKeychainAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 08.07.2022.
//

import Foundation
import Valet

struct LegacyKeychainAgent {
    
    private let valet: Valet
    
    init?() {
        
        guard let identifier = Identifier(nonEmpty: "Druidia") else {
            return nil
        }
        
        self.valet = Valet.valet(with: identifier, accessibility: .whenUnlockedThisDeviceOnly)
    }
    
    var pinCode: String? { try? valet.string(forKey: "pincode") }
    
    func clearPincode() throws {
        
        try valet.removeObject(forKey: "pincode")
    }
}

