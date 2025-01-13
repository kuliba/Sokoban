//
//  URL+appendingQueryItems.swift
//
//
//  Created by Igor Malyarov on 07.09.2024.
//

import Foundation

public extension URL {
    
    /// Appends query parameters to a URL, using a specified value for all parameters.
    ///
    /// - Parameters:
    ///   - parameters: An array of parameter names to be appended as query items.
    ///   - value: The value to assign to each query parameter in the URL.
    ///
    /// - Throws: `URLError.invalidURL` if the URL cannot be constructed.
    ///
    /// - Returns: A new URL with the appended query items. If `parameters` is empty, the URL remains unchanged.
    func appendingQueryItems(
        parameters: [String],
        value: String
    ) throws -> URL {
        
        let parameters = parameters.filter { !$0.isEmpty }
        
        guard !parameters.isEmpty, !value.isEmpty else { return self }
        
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { throw URLError.invalidURL }
        
        let queryItems = parameters.map { URLQueryItem(name: $0, value: value) }
        urlComponents.queryItems = queryItems
        
        if let updatedURL = urlComponents.url {
            return updatedURL
        } else {
            throw URLError.invalidURL
        }
    }
    
    /// Returns a new URL with the given query parameters appended, excluding any parameters with empty keys or values.
    /// Throws an error if the URL components cannot be resolved or if the URL cannot be created.
    ///
    /// - Parameter parameters: A dictionary of query parameters to append to the URL.
    /// - Throws: `URLError.invalidURL` if the URL cannot be created.
    /// - Returns: A URL with the appended query parameters, or the original URL if no valid parameters are provided.
    func appendingQueryItems(
        parameters: [String: String]
    ) throws -> URL {
        
        let parameters = parameters.filter {
            !$0.key.isEmpty && !$0.value.isEmpty
        }
        
        guard !parameters.isEmpty else { return self }
        
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { throw URLError.invalidURL }
        
        let queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        urlComponents.queryItems = queryItems
        
        if let updatedURL = urlComponents.url {
            return updatedURL
        } else {
            throw URLError.invalidURL
        }
    }
    
    /// Appends a "serial" query parameter to the URL if the serial is not nil or empty.
    ///
    /// - Parameter serial: The serial string to append as a query parameter.
    /// - Throws: An error if the URL cannot be updated.
    /// - Returns: A new URL with the appended serial query parameter, or the original URL if the serial is nil or empty.
    func appendingSerial(
        _ serial: String?
    ) throws -> URL {
        
        guard let serial else { return self }
        
        return try appendingQueryItems(parameters: ["serial": serial])
    }
}

public enum URLError: Error {
    
    case invalidURL
}
