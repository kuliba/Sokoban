//
//  SegmentedPaymentProviderPickerView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import SwiftUI

struct SegmentedPaymentProviderPickerView<ProviderView, Footer>: View
where ProviderView: View,
      Footer: View {
    
    let segments: Segments
    let providerView: (SegmentedOperatorProvider) -> ProviderView
    let footer: () -> Footer
    let config: Config
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    
                    ForEach(segments, content: segmentView)
                }
                
                footer()
            }
            .padding()
        }
    }
}

extension SegmentedPaymentProviderPickerView {
    
    typealias Segments = [Segment<SegmentedOperatorProvider>]
    typealias Config = SegmentedPaymentProviderPickerViewConfig
}

extension SegmentedOperatorProvider: Identifiable {
    
    var id: String {
        
        switch self {
        case let .operator(`operator`):
            return "\(`operator`.origin.id)"
            
        case let .provider(provider):
            return provider.origin.id
        }
    }
}

private extension SegmentedPaymentProviderPickerView {
    
    func segmentView(
        segment: Segments.Element
    ) -> some View {
        
        VStack(spacing: 13) {
            
            segment.title.text(withConfig: config.title)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            config.dividerColor
                .frame(height: 0.5)
            
            ForEach(segment.content, content: providerView)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical)
        .background(config.background)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}
