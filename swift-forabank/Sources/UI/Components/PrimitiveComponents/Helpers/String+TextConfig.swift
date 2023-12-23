//
//  String+TextConfig.swift
//  
//
//  Created by Igor Malyarov on 23.12.2023.
//

import SwiftUI

public extension String {
    
    func text(withConfig config: TextConfig) -> some View {
        
        Text(self)
            .font(config.textFont)
            .foregroundColor(config.textColor)
    }
}
