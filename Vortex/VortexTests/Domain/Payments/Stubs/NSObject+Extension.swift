//
//  NSObject+Extension.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.03.2023.
//

import Foundation

extension NSObject {
    
    static func data<T: Decodable>(fromFilename filename: String) throws -> T {
        
        let bundle = Bundle(for: Self.self)
        let decoder = JSONDecoder()
        
        guard let url = bundle.url(forResource: filename, withExtension: "json")
        else {
            throw NSError(domain: "Fail to find file \"\(filename).json\" in bundle", code: 0)
        }
        
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}
