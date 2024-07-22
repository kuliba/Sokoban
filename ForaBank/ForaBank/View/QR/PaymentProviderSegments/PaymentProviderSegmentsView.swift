//
//  PaymentProviderSegmentsView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

import SwiftUI

import SwiftUI

struct PaymentProviderSegmentsView<ProviderView, Footer>: View
where ProviderView: View,
      Footer: View {
    
    let segments: [Segment]
    let providerView: (Provider) -> ProviderView
    let footer: () -> Footer
    let config: Config
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 16) {
                
                ForEach(segments, content: segmentView)
                
                footer()
            }
        }
    }
}

extension PaymentProviderSegmentsView {
    
    typealias Segment = PaymentProviderSegment
    typealias Provider = PaymentProviderSegment.Provider
    typealias Config = PaymentProviderSegmentsViewConfig
}

private extension PaymentProviderSegmentsView {
    
    func segmentView(
        segment: Segment
    ) -> some View {
        
        VStack(spacing: 16) {
            
            segment.title.text(withConfig: config.title)
                .padding(.horizontal)
            
            config.dividerColor
                .frame(height: 0.5)
            
            ForEach(segment.providers, content: providerView)
                .padding(.horizontal)
        }
        .background(config.background)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}


#Preview {
    PaymentProviderSegmentsView(
        segments: .init(with: [SegmentedPaymentProvider].preview),
        providerView: { provider in
            
            VStack {
             
                Text(provider.icon + " " + provider.title)
                provider.inn.map(Text.init)
            }
        },
        footer: { Text("Footer View here.") },
        config: .iFora
    )
}

private extension Array where Element == SegmentedPaymentProvider {
    
    static let preview: Self = [
        .init(id: "1", icon: "", title: "Service A", inn: nil, segment: "Services"),
        .init(id: "2", icon: "", title: "ServiceB", inn: "123", segment: "Services"),
        .init(id: "3", icon: "", title: "FastNet", inn: nil, segment: "Internet"),
        .init(id: "4", icon: "", title: "TV-D", inn: "234", segment: "TV"),
        .init(id: "5", icon: "", title: "TV-F", inn: "3456", segment: "TV"),
    ]
}
