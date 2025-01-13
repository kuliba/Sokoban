//
//  anyError.swift
//  
//
//  Created by Дмитрий Савушкин on 26.10.2023.
//

import Foundation

func anyError(
    _ domain: String = "any error",
    _ code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}
