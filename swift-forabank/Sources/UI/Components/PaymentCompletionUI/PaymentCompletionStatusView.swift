//
//  PaymentCompletionStatusView.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentCompletionStatusView: View {
    
    let state: State
    let config: Config
    
    var body: some View {
        
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
            $0.text(withConfig: config.subtitle)
        }
    }
    
    func formattedAmountView() -> some View {
        
        state.formattedAmount.text(withConfig: config.amount)
    }
    
    @ViewBuilder
    func merchantLogoView() -> some View {
        
        state.merchantIcon.map(logoView)
    }
    
    private func logoView(
        logo: Image
    ) -> some View {
        
        logo
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: config.logoHeight, height: config.logoHeight)
    }
}

#if DEBUG
private extension PaymentCompletionStatus {
    
    static let preview: Self = .init(
        status: .preview,
        formattedAmount: "1 000 ₽",
        merchantIcon: .init(systemName: "pencil.and.outline")
    )
    
    static let withSubtitle: Self = .init(
        status: .withSubtitle,
        formattedAmount: "1 000 ₽",
        merchantIcon: .init(systemName: "tray.full.fill")
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
        subtitle: "Confirmation period expired"
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
            
            tcStatusView(.preview)
            tcStatusView(.withSubtitle)
        }
    }
    
    private static func tcStatusView(
        _ state: PaymentCompletionStatusView.State
    ) -> some View {
        
        PaymentCompletionStatusView(state: state, config: .preview)
    }
}
#endif
