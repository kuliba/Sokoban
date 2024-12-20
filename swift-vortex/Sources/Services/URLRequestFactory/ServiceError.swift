//
//  ServiceError.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

public extension URLRequestFactory.Service {
    
    enum Error: Swift.Error {
        
        case bindPublicKeyWithEventIDEmptyEventID
        case bindPublicKeyWithEventIDEmptyKey
        case emptySessionID
        case emptyData
        case formSessionKeyEmptyCode
        case formSessionKeyEmptyData
    }
}
