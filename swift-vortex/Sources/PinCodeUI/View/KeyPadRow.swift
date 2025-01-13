//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

struct KeyPadRow: View {
    
    let keys: [ButtonInfo]
    let config: ButtonConfig

    var body: some View {
        
        HStack(spacing: 20) {
            
            ForEach(keys, content: keyPadButton)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func keyPadButton(option: ButtonInfo) -> some View {
        
        KeyPadButton(
            buttonInfo: option,
            config: config
        )
    }
}
