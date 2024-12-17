//
//  FraudNoticeView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct FraudNoticeView: View {
    
    let state: FraudNoticePayload
    let event: (FraudEvent) -> Void
    
    var body: some View {
        
        PaymentsAntifraudView(viewModel: .iFora(from: state, event: event))
    }
}

private extension PaymentsAntifraudViewModel {
    
    static func iFora(
        from fraud: FraudNoticePayload,
        event: @escaping (FraudEvent) -> Void
    ) -> PaymentsAntifraudViewModel {
        
        return .init(
            header: .init(),
            main: .init(
                name: fraud.title,
                phone: fraud.subtitle ?? "",
                amount: fraud.formattedAmount,
                timer: .init(
                    delay: .init(fraud.delay),
                    completeAction: { event(.expired) }
                )
            ),
            // TODO: add button config
            bottom: .init(
                cancelButton: .init(
                    title: "Отменить",
                    style: .gray,
                    action: { event(.cancel) }
                ),
                continueButton: .init(
                    title: "Продолжить",
                    style: .gray,
                    action: { event(.consent) }
                )
            )
        )
    }
}

struct FraudNoticeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FraudNoticeView(state: .preview, event: { print($0) })
    }
}

private extension FraudNoticePayload {
    
    static let preview: Self = .init(
        title: "Юрий Андреевич К.",
        subtitle: "+7 (903) 324-54-15",
        formattedAmount: "- 1 000,00 ₽",
        delay: 111
    )
}
