//
//  ServerRequestCreationError.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2023.
//

public enum ServerRequestCreationError: Error {
    
    case unableConstructURL
    case unableConstructURLWithParameters
    case unableEncodePayload(Error)
}
