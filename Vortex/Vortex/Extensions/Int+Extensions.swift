//
//  Int+Extensions.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.07.2022.
//

extension Int {
    
    func indexInRange(min: Int, max: Int) -> Int {
        
        switch self {
        case ..<min: return min
        case max...: return max
        default:
            return self
        }
    }
}
