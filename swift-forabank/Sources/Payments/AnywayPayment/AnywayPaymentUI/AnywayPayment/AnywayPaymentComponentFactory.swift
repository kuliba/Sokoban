//
//  AnywayPaymentComponentFactory.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import SwiftUI

struct AnywayPaymentComponentFactory<Icon, InfoView, InputView, ProductPicker>
where InfoView: View,
      InputView: View,
      ProductPicker: View {
    
    let makeInfoView: MakeInfoView
    let makeInputView: MakeInputView
    let makeProductPicker: MakeProductPicker
}

extension AnywayPaymentComponentFactory {
    
    typealias MakeInfoView = (Info<Icon>) -> InfoView
    
    typealias OnInput = (String) -> Void
    typealias MakeInputView = (InputState<Icon>, @escaping OnInput) -> InputView
    
    typealias OnSelect = (Product) -> Void
    typealias MakeProductPicker = (Product, @escaping OnSelect) -> ProductPicker
}
