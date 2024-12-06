//
//  ServerUploadCommand.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2023.
//

import Foundation

/// Multipart upload server request
public protocol ServerUploadCommand {
    
    associatedtype Response: ServerResponse

    var token: String { get }
    var endpoint: String { get }
    var method: ServerCommandMethod { get }
    var parameters: [ServerCommandParameter]? { get }
    var media: ServerCommandMediaParameter { get }
    var timeout: TimeInterval? { get }
}
