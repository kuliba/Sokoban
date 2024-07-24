//
//  PaymentProviderSegmentsView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

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

extension PaymentProviderSegmentsView {
    
    typealias Segment = PaymentProviderSegment
    typealias Provider = PaymentProviderSegment.Provider
    typealias Config = PaymentProviderSegmentsViewConfig
}

private extension PaymentProviderSegmentsView {
    
    func segmentView(
        segment: Segment
    ) -> some View {
        
        VStack(spacing: 13) {
            
            segment.title.text(withConfig: config.title)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            config.dividerColor
                .frame(height: 0.5)
            
            ForEach(segment.providers, content: providerView)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical)
        .background(config.background)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}


#Preview {
    PaymentProviderSegmentsView(
        segments: .init(with: [SegmentedPaymentProvider].preview),
        providerView: { provider in
            
            VStack(alignment: .leading) {
             
                Text((provider.icon ?? "?") + " " + provider.title)
                provider.inn.map(Text.init)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        },
        footer: { Text("Footer View here.") },
        config: .iFora
    )
}

private extension Array where Element == SegmentedPaymentProvider {
    
    static let preview: Self = [
        .init(id: "1", icon: "i", inn: nil, title: "Service A", segment: "Services"),
        .init(id: "2", icon: "i", inn: "123567890", title: "Service B", segment: "Services"),
        .init(id: "3", icon: "i", inn: nil, title: "FastNet", segment: "Internet"),
        .init(id: "4", icon: "i", inn: "234", title: "TV-D", segment: "TV"),
        .init(id: "5", icon: "i", inn: "3456", title: "TV-F", segment: "TV"),
    ]
}
