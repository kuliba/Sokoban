//
//  MosParkingSelectorView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 12.06.2023.
//

import SwiftUI
import PickerWithPreviewComponent

struct MosParkingSelectorView: View {
        
    @State private var state: ComponentState
    
    public let paymentAction: () -> Void
    public let continueAction: () -> Void

    let model: PickerWithPreviewModel
    
    init(
        initialState: ComponentState,
        options: [SubscriptionType: [OptionWithMapImage]],
        paymentAction: @escaping () -> Void,
        continueAction: @escaping () -> Void
    ) {
        _state = .init(initialValue: initialState)
        self.model = .init(state: initialState, options: options)
        self.paymentAction = paymentAction
        self.continueAction = continueAction
    }
    
    var body: some View {
        
        PickerWithPreviewContainerView(
            model: model,
            viewConfig: .`defaulf`,
            checkUncheckImage: .`default`,
            paymentAction: paymentAction,
            continueAction: continueAction
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct MosParkingSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MosParkingSelectorView(
            initialState: .monthlyOne,
            options: .all,
            paymentAction: {},
            continueAction: {}
        )
        .previewDisplayName("MPMap: Preview")
    }
}
