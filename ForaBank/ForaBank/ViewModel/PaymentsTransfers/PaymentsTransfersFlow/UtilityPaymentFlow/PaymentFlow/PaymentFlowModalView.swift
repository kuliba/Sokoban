//
//  PaymentFlowModalView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct PaymentFlowModalView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        switch state {
        case let .fraud(fraud):
            PaymentsAntifraudView(
                viewModel: .iFora(from: fraud, event: event)
            )
        }
    }
}

extension PaymentFlowModalView {
    
    typealias State = UtilityServicePaymentFlowState.Modal
    typealias Event = ModalEvent
    typealias ModalEvent = FraudEvent // while only one Modal
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

struct PaymentFlowModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        PaymentFlowModalView(state: .fraud(.preview), event: { print($0) })
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
