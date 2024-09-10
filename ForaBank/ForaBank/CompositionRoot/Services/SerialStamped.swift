//
//  SerialStamped.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

struct SerialStamped<Value> {
    
    let value: Value
    let serial: Serial
    
    typealias Serial = String
}

extension SerialStamped: Equatable where Value: Equatable {}

extension SerialStamped where Value == Void {
    
    init(serial: Serial) {
        
        self.init(value: (), serial: serial)
    }
}
