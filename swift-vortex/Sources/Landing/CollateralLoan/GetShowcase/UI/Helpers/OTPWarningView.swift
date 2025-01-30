//
//  OTPWarningView.swift
//
//
//  Created by Valentin Ozerov on 29.01.2025.
//

import SwiftUI

public struct OTPWarningView: View {
    
    let text: String?
    let config: Config
    
    public var body: some View {
        
        text.map {
            
            $0.text(withConfig: config.text)
        }
    }
}

extension OTPWarningView {
    
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig.OTPWarningViewConfig
}
