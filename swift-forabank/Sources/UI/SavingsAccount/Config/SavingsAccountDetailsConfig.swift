//
//  SavingsAccountDetailsConfig.swift
//
//
//  Created by Andryusina Nataly on 02.12.2024.
//

import SharedConfigs
import SwiftUI

struct SavingsAccountDetailsConfig: Equatable {
    
    let chevronDown: Image
    let colors: Colors
    let cornerRadius: CGFloat
    let days: TextConfig
    let heights: Heights
    let info: Image
    let interestDate: TextConfig
    let interestTitle: TextConfig
    let interestSubtitle: TextConfig
    let padding: CGFloat
    let period: TextConfig
    let progressColors: [Color]
    let texts: Texts
    
    struct Heights: Equatable {
        
        let big: CGFloat
        let header: CGFloat
        let interest: CGFloat
        let period: CGFloat
        let progress: CGFloat
        let small: CGFloat
    }
    
    struct Colors: Equatable {
        
        let background: Color
        let chevron: Color
        let progress: Color
        let shimmering: Color
    }
    
    struct Texts: Equatable {
        
        let currentInterest: String
        let header: TextWithConfig
        let minBalance: String
        let paidInterest: String
        let per: String
        
        let days: String
        let interestDate: String
        let period: String
    }
}
