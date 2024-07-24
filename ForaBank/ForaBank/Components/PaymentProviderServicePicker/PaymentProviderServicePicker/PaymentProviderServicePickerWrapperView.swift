//
//  PaymentProviderServicePickerWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import SwiftUI

struct PaymentProviderServicePickerWrapperView<FailureView, ServiceView>: View
where FailureView: View,
      ServiceView: View {
    
    @ObservedObject var model: Model
    
    let failureView: () -> FailureView
    let itemView: (Service) -> ServiceView
    
    var body: some View {
        
        switch model.state.items {
        case .none:
            EmptyView()
                
        case .some([]):
            failureView()
            
        case let .some(items):
            ServicePickerView(state: items, serviceView: itemView)
        }
    }
}

extension PaymentProviderServicePickerWrapperView {
    
    typealias Service = UtilityService
    typealias Model = PaymentProviderServicePickerModel
}

#Preview {
    PaymentProviderServicePickerWrapperView(
        model: .init(
            initialState: .init(
                payload: .init(
                    id: UUID().uuidString,
                    icon: nil,
                    inn: nil,
                    title: "Some Provider"
                )
            ),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        ),
        failureView: { Text("Failure view") },
        itemView: { item in
            
            Button {
                print(item)
            } label: {
                Text("\(item)")
            }
        }
    )
}
