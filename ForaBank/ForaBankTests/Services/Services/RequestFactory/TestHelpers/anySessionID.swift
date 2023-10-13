//
//  anySessionID.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import Foundation

func anySessionID(
    _ value: String = UUID().uuidString
) -> SessionID {
    
    .init(value: value)
}
