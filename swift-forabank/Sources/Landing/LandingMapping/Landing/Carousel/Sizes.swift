//
//  Sizes.swift
//  
//
//  Created by Andryusina Nataly on 13.10.2024.
//

import Foundation

public struct Sizes: Equatable {
    
    public let width: CGFloat
    public let height: CGFloat
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}

extension Sizes {
        
    init(size: String, scale: String) {
        
        let allNumbers = size.allNumbers
        let width = CGFloat(!allNumbers.isEmpty ? allNumbers[0] : 0) * scale.scale()
        let height = CGFloat(allNumbers.count > 1 ? allNumbers[1] : 0) * scale.scale()
        self.init(width: width, height: height)
    }
}

extension String {
    
    var allNumbers: [Int] {
        
        let numbersInString = components(separatedBy: .decimalDigits.inverted).filter { !$0.isEmpty }
        return numbersInString.compactMap { Int($0) }
    }
}

private extension String {
    /*
     https://shorturl.at/5OdQz
     */
    func scale() -> CGFloat {
        
        switch self {
            
        case "small":   return 0.25
        case "medium":  return 1
        case "large":   return 1.25
        default:        return 1
        }
    }
}
