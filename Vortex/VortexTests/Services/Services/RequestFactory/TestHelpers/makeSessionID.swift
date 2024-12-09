//
//  makeSessionID.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import Vortex
import Foundation

func makeSessionID(
    _ value: String = UUID().uuidString
) -> Vortex.SessionID {
    
    .init(sessionIDValue: value)
}
