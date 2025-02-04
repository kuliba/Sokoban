//
//  CollateralLoanLandingParameters+SuccessText.swift
//  Vortex
//
//  Created by Valentin Ozerov on 04.02.2025.
//

public extension CollateralLoanLandingParameters {
    
    struct SuccessText: Equatable {
        
        public typealias ID = CollateralLoanLandingIDs.SuccessTextID
        
        let id: ID
        public let value: String
        public let style: Style
        
        public init(id: ID, value: String, style: Style) {
            
            self.id = id
            self.value = value
            self.style = style
        }
    }
}
