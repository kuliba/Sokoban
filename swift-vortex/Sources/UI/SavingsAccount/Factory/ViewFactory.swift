//
//  ViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 27.11.2024.
//

import SwiftUI

public struct ViewFactory<AmountInfo, OTPView, ProductPicker>
where AmountInfo: View,
      OTPView: View,
      ProductPicker: View {

    let amountInfo: AmountInfo
    let makeOTPView: MakeOTPView
    let makeProductPickerView: MakeProductPickerView
    
    public init(
        amountInfo: AmountInfo,
        makeOTPView: @escaping MakeOTPView,
        makeProductPickerView: @escaping MakeProductPickerView
    ) {
        self.amountInfo = amountInfo
        self.makeOTPView = makeOTPView
        self.makeProductPickerView = makeProductPickerView
    }
}

public extension ViewFactory {
     
    typealias MakeOTPView = () -> OTPView
    typealias MakeProductPickerView = () -> ProductPicker
}
