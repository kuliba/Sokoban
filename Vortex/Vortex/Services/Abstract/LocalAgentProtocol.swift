//
//  LocalAgentProtocol.swift
//  Vortex
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

/// Defines an interface for a local agent responsible for storing, loading, and managing serials for data.
protocol LocalAgentProtocol {
    
    /// Stores the given encodable data with an optional serial identifier.
    /// - Parameters:
    ///   - data: The data to store, conforming to `Encodable`.
    ///   - serial: An optional serial identifier for the data.
    func store<T: Encodable>(_ data: T, serial: String?) throws
    
    /// Loads the stored data of the specified type.
    /// - Parameter type: The type of data to load.
    /// - Returns: An instance of the requested type if available, otherwise `nil`.
    func load<T: Decodable>(type: T.Type) -> T?
    
    /// Clears the stored data for the specified type.
    /// - Parameter type: The type of data to clear.
    func clear<T>(type: T.Type) throws
    
    /// Retrieves the serial identifier for the specified type.
    /// - Parameter type: The type of data.
    /// - Returns: The associated serial identifier, or `nil` if unavailable.
    func serial<T>(for type: T.Type) -> String?
    
    /// Generates a file name for storing the given type.
    /// - Parameter type: The type of data.
    /// - Returns: A sanitized file name string.
    func fileName<T>(for type: T.Type) -> String
}

extension LocalAgentProtocol {
    
    /// Generates a file name based on the type name.
    /// - Parameter type: The type of data.
    /// - Returns: A sanitized, lowercased file name in JSON format.
    func fileName<T>(for type: T.Type) -> String {
        
        "\(type.self).json"
            .lowercased()
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
    }
}
