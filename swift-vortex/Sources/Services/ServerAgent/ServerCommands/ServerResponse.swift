//
//  ServerResponse.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2023.
//

/// Regular server request response
public protocol ServerResponse: Decodable, Equatable {
    
    associatedtype Payload: Decodable
    
    var statusCode: ServerStatusCode { get }
    var errorMessage: String? { get }
    var data: Payload? { get }
}
