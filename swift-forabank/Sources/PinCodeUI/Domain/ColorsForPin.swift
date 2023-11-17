//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

import SwiftUI

extension PinCodeView.DotView {
    
    public struct ColorsForPin: Equatable {
        
        public let normal: Color
        public let incorrect: Color
        public let correct: Color
        public let printing: Color
        
        public init(
            normal: Color,
            incorrect: Color,
            correct: Color,
            printing: Color
        ) {
            
            self.normal = normal
            self.incorrect = incorrect
            self.correct = correct
            self.printing = printing
        }
        
        func colorByStyle(_ style: PinCodeViewModel.Style, isFilled: Bool) -> Color {
            
            if isFilled {
                
                switch style {
                    
                case .normal:
                    return normal
                    
                case .correct:
                    return correct
                    
                case .incorrect:
                    return incorrect
                    
                case .printing:
                    return printing
                }
                
            } else {
                
                return normal
            }
        }
    }
}
