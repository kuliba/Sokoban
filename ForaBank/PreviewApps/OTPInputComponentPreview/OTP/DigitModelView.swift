//
//  DigitModelView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct DigitModelView: View {
    
    let model: OTPInputState.DigitModel
    
    var body: some View {
        
        VStack {
            
            Text(model.value)
                .font(.largeTitle)
            
            Rectangle()
                .frame(width: 32, height: 1)
                .foregroundStyle(.gray)
        }
    }
}

struct DigitModelView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DigitModelView(model: .init(id: 1, value: "1"))
    }
}
