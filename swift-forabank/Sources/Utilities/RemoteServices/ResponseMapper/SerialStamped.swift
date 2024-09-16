//
//  SerialStamped.swift
//
//
//  Created by Igor Malyarov on 11.09.2024.
//

public struct SerialStamped<Serial, T> {
    
    public let list: [T]
    public let serial: Serial
    
    public init(
        list: [T],
        serial: Serial
    ) {
        self.list = list
        self.serial = serial
    }
}

extension SerialStamped: Equatable where Serial: Equatable, T: Equatable {}
