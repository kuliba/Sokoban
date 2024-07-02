//
//  OTPWarningView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.06.2024.
//

import SwiftUI

struct OTPWarningView: View {
    
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
