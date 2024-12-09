//
//  ServerDownloadCommand.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2023.
//

import Foundation

/// Multipart download server request
public protocol ServerDownloadCommand {
    
    associatedtype Payload: Encodable
    typealias Response = Data
    
    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var payload: Payload? { get }
    var timeout: TimeInterval? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}
