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
}

public enum URLError: Error {
    
    case invalidURL
}
