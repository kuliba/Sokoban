//
//  PaymentProviderServicePickerWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import Combine
import FooterComponent
import SwiftUI
import UIPrimitives

struct PaymentProviderServicePickerWrapperView: View {
    
    @ObservedObject var model: Model
    
    let failureView: () -> FooterView
    let iconView: (IconDomain.Icon?) -> IconDomain.IconView
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
    
    private func itemView(
        _ service: UtilityService
    ) -> some View {
        
        Button {
            model.event(.select(service))
        } label: {
            LabelWithIcon(
                title: service.name,
                subtitle: nil,
                config: .iFora,
                iconView: iconView(nil)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaymentProviderServicePickerWrapperView(
        model: .init(
            initialState: .init(payload: .preview),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        ),
        failureView: {
            
            FooterView(
                state: .failure(.iFora),
                event: { print($0) },
                config: .iFora
            )
        },
        iconView: { item in
            
            return .init(
                image: .init(systemName: "photo"), publisher:
                    Just(.init(systemName: "photo")).eraseToAnyPublisher()
            )
        },
        config: .iFora
    )
}
