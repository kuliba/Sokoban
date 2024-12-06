//
//  makeSessionID.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import Foundation

func makeSessionID(
    _ value: String = UUID().uuidString
) -> ForaBank.SessionID {
    
    .init(sessionIDValue: value)
}
