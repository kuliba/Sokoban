//
//  HTTPClientSpy+ext.swift
//  VortexTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import XCTest

extension HTTPClientSpy {
    
    func assert(
        queryItems expectedQueryItems: [[URLQueryItem]],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(queryItems, expectedQueryItems, "Expected \(expectedQueryItems), got \(queryItems) instead.", file: file, line: line)
    }
    
    var queryItems: [[URLQueryItem]] {
        
        requests
            .compactMap(\.url)
            .compactMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
            .compactMap(\.queryItems)
    }
    
    func lastPathComponentsWithQueryValue(for name: String) -> [String?] {
        
        requests.map { $0.url?.lastPathComponentWithQueryValue(for: name) }
    }
}

extension URL {
    
    /// Returns the last path component and the value of a query item for a given name, separated by a dash.
    /// - Parameter name: The name of the query item to retrieve.
    /// - Returns: A string in the format "lastPathComponent-value", or just "lastPathComponent" if the query item doesn't exist.
    func lastPathComponentWithQueryValue(for name: String) -> String {
        
        var result = self.lastPathComponent
        
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let value = queryItems.first(where: { $0.name == name })?.value {
            
            result += "-\(value)"
        }
        
        return result
    }
}
