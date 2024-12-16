//
//  String+ext.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation

public extension String {
    
    func formatted(
        withChunkSize chunkSize: Int = 4,
        withSeparator separator: String = " "
    ) -> String {
        var stringWithAddedSpaces = ""
        
        for i in Swift.stride(from: 0, to: self.count, by: 1) {
            if i > 0 && (i % chunkSize) == 0 {
                stringWithAddedSpaces.append(contentsOf: separator)
            }
            let characterToAdd = self[self.index(self.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
}
