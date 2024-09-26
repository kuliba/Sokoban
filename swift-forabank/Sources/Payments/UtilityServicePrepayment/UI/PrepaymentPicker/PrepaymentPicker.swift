//
//  PrepaymentPicker.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI
import UtilityServicePrepaymentDomain

public struct PrepaymentPicker<LastPayment, Operator, FooterView, LastPaymentView, OperatorView, SearchView>: View
where LastPayment: Identifiable,
      Operator: Identifiable,
      FooterView: View,
      LastPaymentView: View,
      OperatorView: View,
      SearchView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        switch state {
        case .failure:
            factory.makeFooterView(true)
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity)
            
        case let .success(success):
            PrepaymentPickerSuccessView(state: success, event: event, factory: factory)
        }
    }
}

public extension PrepaymentPicker {
    
    typealias State = PrepaymentPickerState<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    
    typealias Factory = PrepaymentPickerFactory<LastPayment, Operator, SearchView, LastPaymentView, OperatorView, FooterView>
}

struct ComposedOperatorsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PrepaymentPicker(
                state: .success(.preview),
                event: { print($0) },
                factory: .preview
            )
            
            PrepaymentPicker(
                state: PrepaymentPickerState<PreviewLastPayment, PreviewOperator>.failure(NSError(domain: "PrepaymentPicker", code: -1)),
                event: { print($0) },
                factory: .preview
            )
        }
    }
}
