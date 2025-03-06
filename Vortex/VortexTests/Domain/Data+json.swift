//
//  Data+json.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import XCTest

extension Data {
    
    func jsonDict(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> NSDictionary {
        
        let json = try JSONSerialization.jsonObject(with: self) as? [String: Any]
        let result = try XCTUnwrap(json, "Expected valid JSON", file: file, line: line)
        
        return result as NSDictionary
    }
    
    func jsonArray(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> NSArray {
        
        let json = try JSONSerialization.jsonObject(with: self) as? [Any]
        let result = try XCTUnwrap(json, "Expected valid JSON Array", file: file, line: line)
        
        return result as NSArray
    }
}
