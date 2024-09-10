//
//  SerialStamped.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

public struct SerialStamped<Value> {
    
    public let value: Value
    public let serial: Serial?
    
    public init(
        value: Value,
        serial: Serial?
    ) {
        self.value = value
        self.serial = serial
    }
    
    public typealias Serial = String
}

extension SerialStamped: Equatable where Value: Equatable {}

public extension SerialStamped where Value == Void {
    
    init(serial: Serial) {
        
        self.init(value: (), serial: serial)
    }
}
