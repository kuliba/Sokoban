//
//  ViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 27.11.2024.
//

import SwiftUI

public struct ViewFactory<OTPView, ProductPicker> 
where OTPView: View,
      ProductPicker: View {

    let makeOTPView: MakeOTPView
    let makeProductPickerView: MakeProductPickerView
    
    public init(
        makeOTPView: @escaping MakeOTPView,
        makeProductPickerView: @escaping MakeProductPickerView
    ) {
        self.makeOTPView = makeOTPView
        self.makeProductPickerView = makeProductPickerView
    }
}

public extension ViewFactory {
        
    typealias MakeOTPView = () -> OTPView
    typealias MakeProductPickerView = () -> ProductPicker
}
