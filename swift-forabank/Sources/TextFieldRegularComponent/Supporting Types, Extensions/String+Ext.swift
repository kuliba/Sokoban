//
//  String+Extensions.swift
//
//
//  Created by Igor Malyarov on 11.04.2023
//

import Foundation

extension String {
    
    func shouldChangeTextIn(
        range: NSRange,
        with replacementText: String
    ) -> String {
        
        guard
            range.location + range.length >= 0,
            let rangeStart = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let rangeEnd = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
        else {
            return replacementText
        }
        
        var copy = self
        copy.replaceSubrange(rangeStart..<rangeEnd, with: replacementText)
        
        return copy
    }
}
