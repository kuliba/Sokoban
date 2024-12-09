//
//  URL+StaticString.swift
//  VortexTests
//
//  Created by Igor Malyarov on 04.08.2023.
//

import Foundation

extension URL {
    
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)")
        else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
}
