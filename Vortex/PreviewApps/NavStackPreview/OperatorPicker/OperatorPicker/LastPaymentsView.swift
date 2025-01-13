//
//  LastPaymentsView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct LastPaymentsView<Icon>: View {
    
    let state: State
    let event: (LastPayment) -> Void
    let config: Config

    var body: some View {
        
        HStack {
            
            ForEach(state, content: lastPaymentView)
        }
    }
    
    private func lastPaymentView(
        lastPayment: LastPayment
    ) -> some View {
        
        Button(String(describing: lastPayment).prefix(6)) {
            
            event(lastPayment)
        }
    }
}

extension LastPaymentsView {
    
    typealias LastPayment = UtilityPaymentOperatorPickerState<Icon>.LastPayment
    typealias State = [LastPayment]
    typealias Config = LastPaymentsViewConfig
}

struct LastPaymentsViewConfig {}
