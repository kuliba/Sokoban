//
//  DigitModelView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI
import UIPrimitives

struct DigitModelView: View {
    
    let model: DigitModel
    let config: DigitModelConfig
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            model.value.text(withConfig: config.digitConfig)
            
            Rectangle()
                .frame(width: 40, height: 1)
                .foregroundColor(config.rectColor)
        }
    }
}

struct DigitModelView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DigitModelView(
            model: .init(id: 1, value: "1"),
            config: .preview
        )
    }
}
