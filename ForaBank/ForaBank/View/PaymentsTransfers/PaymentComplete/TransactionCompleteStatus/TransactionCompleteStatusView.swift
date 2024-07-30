//
//  TransactionCompleteStatusView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

struct TransactionCompleteStatusView: View {
    
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

extension TransactionCompleteStatusView {
    
    typealias State = TransactionCompleteStatus
    typealias Config = TransactionCompleteStatusViewConfig
}

private extension TransactionCompleteStatusView {
    
    func iconView() -> some View {
        
        state.status.logo
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .foregroundColor(.iconWhite)
            .frame(width: 88, height: 88)
            .background(
                Circle()
                    .foregroundColor(config.logoBackgroundColor)
            )
            .accessibilityIdentifier("SuccessPageStatusIcon")
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
        
        state.merchantLogo.map(logoView)
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
private extension TransactionCompleteStatus {
    
    static let preview: Self = .init(
        status: .preview,
        formattedAmount: "1 000 ₽",
        merchantLogo: .ic24Bank
    )
    
    static let withSubtitle: Self = .init(
        status: .withSubtitle,
        formattedAmount: "1 000 ₽",
        merchantLogo: .ic24Bank
    )
}

private extension TransactionCompleteStatus.Status {
    
    static let preview: Self = .init(
        logo: .ic24Star,
        title: "Payment completed",
        subtitle: nil
    )
    
    static let withSubtitle: Self = .init(
        logo: .ic24Star,
        title: "Payment cancelled",
        subtitle: "Confirmation period expired"
    )
}

private extension TransactionCompleteStatusViewConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .textGreen
        ),
        logoBackgroundColor: .green,
        title: .init(
            textFont: .textH1Sb24322(),
            textColor: .textRed
        ),
        subtitle: .init(
            textFont: .textH3Sb18240(),
            textColor: .textGreen
        ),
        logoHeight: 40
    )
}

struct TransactionCompleteStatusView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            tcStatusView(.preview)
            tcStatusView(.withSubtitle)
        }
    }
    
    private static func tcStatusView(
        _ state: TransactionCompleteStatusView.State
    ) -> some View {
        
        TransactionCompleteStatusView(state: state, config: .preview)
    }
}
#endif
