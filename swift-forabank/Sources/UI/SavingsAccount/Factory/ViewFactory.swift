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

    let makeAmountInfoView: MakeAmountInfoView
    let makeOTPView: MakeOTPView
    let makeProductPickerView: MakeProductPickerView
    
    public init(
        makeAmountInfoView: @escaping MakeAmountInfoView,
        makeOTPView: @escaping MakeOTPView,
        makeProductPickerView: @escaping MakeProductPickerView
    ) {
        self.makeAmountInfoView = makeAmountInfoView
        self.makeOTPView = makeOTPView
        self.makeProductPickerView = makeProductPickerView
    }
}

public extension ViewFactory {
     
    typealias MakeAmountInfoView = () -> AmountInfo
    typealias MakeOTPView = () -> OTPView
    typealias MakeProductPickerView = () -> ProductPicker
}
