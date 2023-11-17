//
//  FormSessionKeyPayload.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

extension URLRequestFactory.Service {
    
    public struct FormSessionKeyPayload {
        
        public let code: Code
        public let data: Data
        
        public init(
            code: Code,
            data: Data
        ) {
            self.code = code
            self.data = data
        }
        
        func json() throws -> Data {
            
            guard !code.value.isEmpty
            else {
                throw Error.formSessionKeyEmptyCode
            }
            
            guard !data.isEmpty
            else {
                throw Error.formSessionKeyEmptyData
            }
            
            return try JSONSerialization.data(withJSONObject: [
                "code": code.value,
                "data": data.base64EncodedString()
            ] as [String: String])
        }
        
        public struct Code {
            
            public let value: String
            
            public init(value: String) {
             
                self.value = value
            }
        }
    }
}
