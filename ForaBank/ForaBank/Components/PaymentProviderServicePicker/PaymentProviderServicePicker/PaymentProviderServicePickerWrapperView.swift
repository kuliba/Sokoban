//
//  PaymentProviderServicePickerWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentProviderServicePickerWrapperView<FailureView, ServiceView>: View
where FailureView: View,
      ServiceView: View {
    
    @ObservedObject var model: Model
    
    let failureView: () -> FailureView
    let itemView: (Service) -> ServiceView
    let config: Config

    var body: some View {
        
        Group {
            
            switch model.state.items {
            case .none:
                Color.clear.opacity(0.01)
                
            case .some([]):
                failureView()
                
            case let .some(items):
                ServicePickerView(state: items, serviceView: serviceView)
            }
        }
        .onFirstAppear { model.event(.load) }
    }
}

extension PaymentProviderServicePickerWrapperView {
    
    typealias Service = UtilityService
    typealias Model = PaymentProviderServicePickerModel
    typealias Config = PaymentProviderServicePickerConfig
}

private extension PaymentProviderServicePickerWrapperView {
    
    func serviceView(
        service: UtilityService
    ) -> some View {
        
        itemView(service)
            .padding()
            .background(config.background)
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}

#Preview {
    PaymentProviderServicePickerWrapperView(
        model: .init(
            initialState: .init(payload: .preview),
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
        },
        config: .iFora
    )
}
