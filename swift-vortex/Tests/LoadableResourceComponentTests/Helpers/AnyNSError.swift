//
//  AnyNSError.swift
//  
//
//  Created by Igor Malyarov on 29.06.2023.
//

import Foundation

func anyNSError(
    domain: String = "any error",
    code: Int = 0
) -> NSError {
    
    NSError(domain: domain, code: code)
}
