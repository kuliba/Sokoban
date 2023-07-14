//
//  LocalAgentStub+convenience.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

@testable import ForaBank
import Foundation

extension LocalAgentStub {
    
    convenience init<T: Encodable>(
        type: T.Type = T.self,
        value: T
    ) throws {
        
        let key = "\(type.self)"
        let data = try JSONEncoder().encode(value)
        
        self.init(stub: [key: data])
    }
}
