//
//  SliderEvent.swift
//  
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public enum SliderEvent: Equatable {
    
    case drag(CGFloat)
    case dragEnded(CGFloat)
}
