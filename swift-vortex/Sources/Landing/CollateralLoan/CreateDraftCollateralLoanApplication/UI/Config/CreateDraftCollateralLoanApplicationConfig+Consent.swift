//
//  CreateDraftCollateralLoanApplicationConfig+Consent.swift
//  
//
//  Created by Valentin Ozerov on 01.02.2025.
//

import Foundation
import SwiftUI

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Consent {

        public let checkBoxSize: CGSize
        public let horizontalSpacing: CGFloat
        public let images: Images
        
        public init(
            checkboxSize: CGSize,
            horizontalSpacing: CGFloat,
            images: Images
        ) {
            self.checkBoxSize = checkboxSize
            self.horizontalSpacing = horizontalSpacing
            self.images = images
        }
        
        public struct Images {
            
            let checkOn: Image
            let checkOff: Image
            
            public init(
                checkOn: Image,
                checkOff: Image
            ) {
                self.checkOn = checkOn
                self.checkOff = checkOff
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Consent {
    
    static let preview = Self(
        checkboxSize: .init(width: 24, height: 24),
        horizontalSpacing: 8,
        images: .init(
            checkOn: Image("Checkbox_active"),
            checkOff: Image("Checkbox_normal")
        )
    )
}
