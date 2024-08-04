//
//  ComposedPaymentProviderPickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct ComposedPaymentProviderPickerFlowView: View {
    
    let flowModel: FlowModel
    let iconView: (IconDomain.Icon?) -> IconDomain.IconView
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

extension ComposedPaymentProviderPickerFlowView {
    
    typealias FlowModel = PaymentProviderPickerFlowModel
}

private extension ComposedPaymentProviderPickerFlowView {
    
    func label(
        provider: SegmentedOperatorProvider
    ) -> some View {
        
        LabelWithIcon(
            title: provider.title,
            subtitle: provider.subtitle,
            config: .iFora,
            iconView: iconView(provider.icon)
        )
    }
}

extension SegmentedOperatorProvider {
    
    var subtitle: String? {
        
        switch self {
        case let .operator(`operator`):
            return `operator`.origin.synonymList.first
            
        case let .provider(provider):
            return provider.origin.inn
        }
    }
    
    var icon: IconDomain.Icon? {
        
        switch self {
        case let .operator(`operator`):
            return `operator`.origin.svg.map { .svg($0) }
            
        case let .provider(provider):
            return provider.origin.icon.map { .md5Hash(.init($0)) }
        }
    }
}

private extension OperatorGroupData.OperatorData {
    
    var svg: String? {
        
        logotypeList.first?.svgImage?.description
    }
}
