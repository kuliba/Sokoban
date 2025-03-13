//
//  NullLocalAgent.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.03.2025.
//

/// A no-op implementation of `LocalAgentProtocol` that does nothing.
/// This is useful as a placeholder or default implementation when a local agent is not needed.
final class NullLocalAgent {}

extension NullLocalAgent: LocalAgentProtocol {
    
    /// Does nothing and does not store any data.
    func store<T: Encodable>(_ data: T, serial: String?) throws {}
    
    /// Always returns `nil`, indicating no data is available.
    func load<T: Decodable>(type: T.Type) -> T?  { nil }
    
    /// Does nothing and does not clear any data.
    func clear<T>(type: T.Type) throws {}
    
    /// Always returns `nil`, indicating no serial is available.
    func serial<T>(for type: T.Type) -> String? { nil }
}
