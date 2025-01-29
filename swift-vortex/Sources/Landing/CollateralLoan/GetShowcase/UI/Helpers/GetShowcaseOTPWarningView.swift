//
//  GetShowcaseOTPWarningView.swift
//
//
//  Created by Valentin Ozerov on 29.01.2025.
//

import SwiftUI

struct GetShowcaseOTPWarningView: View {
    
    let text: String?
    let config: Config
    
    var body: some View {
        
        text.map {
            
            $0.text(withConfig: config.text)
        }
    }
}

extension OTPWarningView {
    
    typealias Config = OTPWarningViewConfig
}
