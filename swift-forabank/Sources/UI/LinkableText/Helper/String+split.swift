//
//  String+split.swift
//  
//
//  Created by Igor Malyarov on 31.08.2023.
//

import Foundation

enum Content: Equatable {
 
    case insideTag(String)
    case outsideTag(String)
}

extension String {
    
    func split(
        with tag: (`prefix`: String, suffix: String)
    ) -> [Content] {
        
        let input = self
        var results: [Content] = []
        var currentIndex = input.startIndex
        
        while currentIndex < input.endIndex {
            if let start = input.range(of: tag.prefix, range: currentIndex..<input.endIndex),
               let end = input.range(of: tag.suffix, range: start.upperBound..<input.endIndex) {
                
                if start.lowerBound != currentIndex {
                    let outsideContent = String(input[currentIndex..<start.lowerBound])
                    results.append(.outsideTag(outsideContent))
                }
                
                let tagContent = String(input[start.upperBound..<end.lowerBound])
                results.append(.insideTag(tagContent))
                
                currentIndex = end.upperBound
            } else {
                let outsideContent = String(input[currentIndex..<input.endIndex])
                results.append(.outsideTag(outsideContent))
                break
            }
        }
        
        return results
    }
}
