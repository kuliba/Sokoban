//
//  ButtonStyles.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import SwiftUI

struct OperationDetailsActionButton: ButtonStyle {
    
    let width: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding()
            .frame(minWidth: width)
            .background(Color(hex: "F6F6F7"))
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
