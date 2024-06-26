//
//  anyError.swift
//  
//
//  Created by Igor Malyarov on 24.06.2024.
//

import Foundation

func anyError(_ domain: String = "any error") -> Error {
    
    NSError(domain: domain, code: -1)
}
