//
//  PaymentCompletionStatusView.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import Combine
import SwiftUI
import UIPrimitives

public struct PaymentCompletionStatusView: View {
    
    let state: State
    let makeIconView: MakeIconView
    let config: Config
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            iconView()
            titleView()
            subtitleView()
            formattedAmountView()
            merchantLogoView()
        }
        .padding(.top, 88)
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension PaymentCompletionStatusView {
    
    typealias State = PaymentCompletionStatus
    public typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    typealias Config = PaymentCompletionStatusViewConfig
}

private extension PaymentCompletionStatusView {
    
    func iconView() -> some View {
        
        state.status.logo
            .resizable()
            .scaledToFit()
            .foregroundColor(config.icon.foregroundColor)
            .frame(config.icon.innerSize)
            .frame(config.icon.outerSize)
            .background(
                Circle()
                    .foregroundColor(config.icon.backgroundColor)
            )
            .accessibilityIdentifier("PaymentCompletionStatusIcon")
    }
    
    func titleView() -> some View {
        
        state.status.title.text(withConfig: config.title)
    }
    
    func subtitleView() -> some View {
        
        state.status.subtitle.map {
            
            $0.text(withConfig: config.subtitle, alignment: .center)
        }
    }
    
    func formattedAmountView() -> some View {
        
        state.formattedAmount.text(withConfig: config.amount)
    }
    
    @ViewBuilder
    func merchantLogoView() -> some View {
        
        makeIconView(state.merchantIcon)
            .frame(width: config.logoHeight, height: config.logoHeight)
    }
}

#if DEBUG
private extension PaymentCompletionStatus {
    
    static let preview: Self = .init(
        status: .preview,
        formattedAmount: "1 000 ₽",
        merchantIcon: nil
    )
    
    static let withSubtitle: Self = .init(
        status: .withSubtitle,
        formattedAmount: "1 000 ₽",
        merchantIcon: nil
    )
}

private extension PaymentCompletionStatus.Status {
    
    static let preview: Self = .init(
        logo: .init(systemName: "xmark.bin"),
        title: "Payment completed",
        subtitle: nil
    )
    
    static let withSubtitle: Self = .init(
        logo: .init(systemName: "xmark.bin.circle"),
        title: "Payment cancelled",
        subtitle: "Payment cancelled due to confirmation period expiration"
    )
}

private extension PaymentCompletionStatusViewConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .subheadline,
            textColor: .pink
        ),
        icon: .init(
            foregroundColor: .green,
            backgroundColor: .orange,
            innerSize: .init(width: 44, height: 44),
            outerSize: .init(width: 88, height: 88)
        ),
        logoHeight: 40,
        title: .init(
            textFont: .title3,
            textColor: .blue
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .orange
        )
    )
}

struct PaymentCompletionStatusView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            paymentCompletionStatusView(.preview)
            paymentCompletionStatusView(.withSubtitle)
        }
    }
    
    private static func paymentCompletionStatusView(
        _ state: PaymentCompletionStatusView.State
    ) -> some View {
        
        PaymentCompletionStatusView(
            state: state,
            makeIconView: {
                
                return .init(
                    image: .init(systemName: $0 ?? "pencil.and.outline"),
                    publisher: Just(.init(systemName: $0 ?? "tray.full.fill")).eraseToAnyPublisher()
                )
            },
            config: .preview
        )
    }
}
#endif
