//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 14.10.2023.
//

import Foundation

func anyKeyTag(
    _ value: String = UUID().uuidString
) -> KeyTag {
    
    .init(value: value)
}

func anyKey(
    _ value: String = UUID().uuidString
) -> Key {
    
    .init(value: .init(value.utf8))
}
