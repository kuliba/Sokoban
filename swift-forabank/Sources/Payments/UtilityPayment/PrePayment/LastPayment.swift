//
//  LastPayment.swift
//
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Foundation

public struct LastPayment: Equatable, Identifiable {
    
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        
        self.id = id
    }
}
