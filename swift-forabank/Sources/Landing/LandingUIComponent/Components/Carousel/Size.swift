//
//  Size.swift
//  
//
//  Created by Andryusina Nataly on 13.10.2024.
//

import Foundation
import UIKit

public struct Size: Equatable {
    
    public let width: Int
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

extension Size {
    
    func newHeight(_ padding: CGFloat) -> CGFloat {
        
        return ((UIScreen.main.bounds.width - padding * 2) * CGFloat(height) / CGFloat(width)).rounded(.toNearestOrEven)
    }
}
