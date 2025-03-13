//
//  BackendFailure.swift
//
//
//  Created by Valentin Ozerov on 14.02.2025.
//

import Foundation

public struct BackendFailure<InformerPayload>: Error, Identifiable {
    
    public var id: UUID
    public let kind: Kind
    
    public init(
        id: UUID = UUID(),
        kind: Kind
    ) {
        self.id = id
        self.kind = kind
    }
}

public extension BackendFailure {
    
    enum Kind {
        
        case alert(String)
        case informer(InformerPayload)
        case failureResultScreen
        case offlineForm
    }
}

extension BackendFailure: Equatable where InformerPayload: Equatable {}
extension BackendFailure.Kind: Equatable where InformerPayload: Equatable {}
