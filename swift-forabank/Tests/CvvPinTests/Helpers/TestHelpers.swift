//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import CvvPin
import Foundation

func uniqueSessionCode() -> SessionCode {
    
    .init(value: UUID().uuidString)
}

extension SessionCode {
    
    var local: LocalSessionCode {
        
        .init(value: value)
    }
}

extension LocalSessionCode {
    
    static let empty: Self = .init(value: "")
    
    var toModel: SessionCode {
        
        .init(value: value)
    }
}

func anyNSError(
    domain: String = "any NSError",
    code: Int = 0
) -> NSError {
    
    .init(domain: domain, code: code)
}

func anyURL(string: String = "any-url.com") -> URL {
    
    .init(string: string)!
}
