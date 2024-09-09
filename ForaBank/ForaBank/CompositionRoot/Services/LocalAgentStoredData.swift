//
//  LocalAgentStoredData.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

struct LocalAgentStoredData<Value> {
    
    let value: Value
    let serial: Serial?
    
    typealias Serial = String
}

extension LocalAgentStoredData: Equatable where Value: Equatable {}
