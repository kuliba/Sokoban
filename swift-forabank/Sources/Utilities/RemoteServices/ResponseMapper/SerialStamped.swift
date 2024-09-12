//
//  SerialStamped.swift
//
//
//  Created by Igor Malyarov on 11.09.2024.
//

public struct SerialStamped<T> {
    
    public let list: [T]
    public let serial: String
    
    public init(
        list: [T],
        serial: String
    ) {
        self.list = list
        self.serial = serial
    }
}

extension SerialStamped: Equatable where T: Equatable {}
