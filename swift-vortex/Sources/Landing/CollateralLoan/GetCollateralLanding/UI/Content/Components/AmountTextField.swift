//
//  AmountTextField.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 10.03.2025.
//

import SwiftUI
import UIKit

public struct AmountTextField: UIViewRepresentable {

    public func makeUIView(context: Context) -> UITextField {
        
        let amountTextField = UITextField()
        return amountTextField
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
    }
}
