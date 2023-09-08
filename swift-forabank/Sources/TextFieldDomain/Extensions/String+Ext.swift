//
//  String+Extensions.swift
//
//
//  Created by Igor Malyarov on 11.04.2023
//

import Foundation

extension String {
    
    public func shouldChangeTextIn(
        range: NSRange,
        with replacementText: String
    ) -> String {
        
        let valid = (0...utf16.count)
        
        guard
            valid ~= range.location,
            valid ~= range.location + range.length,
            let rangeStart = self.utf16.index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let rangeEnd = self.utf16.index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
        else {
            return replacementText
        }
        
        var copy = self
        copy.replaceSubrange(rangeStart..<rangeEnd, with: replacementText)
        
        return copy
    }
}
