//
//  SerialStamped.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

struct SerialStamped<Value> {
    
    let value: Value
    let serial: Serial?
    
    typealias Serial = String
}

extension SerialStamped: Equatable where Value: Equatable {}
