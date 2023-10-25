//
//  ServerCommand.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2023.
//

import Foundation

/// Regular server request
public protocol ServerCommand: CustomDebugStringConvertible {
    
    associatedtype Payload: Encodable
    associatedtype Response: ServerResponse
    
    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
    var timeout: TimeInterval? { get }
    var cookiesProvider: Bool { get }
}
