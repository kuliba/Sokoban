//
//  NSRange+clamped.swift
//  
//
//  Created by Igor Malyarov on 15.12.2023.
//

import Foundation

public extension NSRange {
    
    func clamped(
        to string: String,
        droppingLast n: Int
    ) -> NSRange {
        
        let effectiveLength = max(string.count - n, 0)
        let clampedLocation = min(max(location, 0), effectiveLength)
        let clampedLength = min(length, effectiveLength - clampedLocation)

        return .init(location: clampedLocation, length: clampedLength)
    }
}
