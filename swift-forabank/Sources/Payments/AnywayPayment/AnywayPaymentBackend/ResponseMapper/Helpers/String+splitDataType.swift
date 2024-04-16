//
//  String+splitDataType.swift
//
//
//  Created by Igor Malyarov on 03.04.2024.
//

extension String {
    
    func splitDataType() throws -> [(key: String, value: String)] {
        
        enum SplitError: Error {
            
            case tooShortString
        }
        
        let body = dropFirst(2)
        
        guard let separator = prefix(2).last,
              first == "=",
              !body.isEmpty
        else { throw SplitError.tooShortString }
        
        return body.split(separator: separator).compactMap {
            
            let splits = $0.split(separator: "=", maxSplits: 2)
            
            guard splits.count == 2,
                  let key = splits.first, !key.isEmpty,
                  let value = splits.last, !value.isEmpty
            else { return nil }
            
            return (.init(key), .init(value))
        }
    }
}
