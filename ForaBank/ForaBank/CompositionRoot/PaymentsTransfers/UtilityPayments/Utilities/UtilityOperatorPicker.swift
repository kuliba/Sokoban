//
//  UtilityOperatorPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import OperatorsListComponents
import PrePaymentPicker
import FooterComponent
import SwiftUI
import UtilityServicePrepaymentUI

struct UtilityOperatorPicker: View {
    
    let state: UtilitiesViewModel.State
    let event: (UtilityPaymentEvent) -> Void
    
    var body: some View {
        
        switch state.uiState {
            
        case . failure:
            failureView()
            
        case let .options(state):
            PrepaymentPicker(
                state: .init(
                    lastPayments: state.lastPayments,
                    operators: state.operators,
                    searchText: state.searchText
                ),
                event: { event(.composed($0)) },
                factory: .init(
                    makeFooterView: footerView,
                    makeLastPaymentView: lastPaymentView,
                    makeOperatorView: operatorView,
                    makeSearchView: searchView
                )
            )
        }
    }
    
    typealias LastPayment = UtilityPaymentLastPayment
    
#warning("fix `makeIconView`")
    private func lastPaymentView(
        latestPayment: LastPayment
    ) -> some View {
        
        Button {
            // event(.composed(.selectLastOperation(latestPayment)))
            #warning("FIXME")
            fatalError()
        } label: {
            LastPaymentLabel(
                amount: latestPayment.amount,
                title: latestPayment.title,
                config: .iFora,
                iconView: Text("TBD Icon View")
            )
            .contentShape(Rectangle())
        }
    }
    
    typealias Operator = UtilityPaymentOperator
    
#warning("fix `makeIconView`")
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        Button {
            // event(.composed(.selectOperator(`operator`)))
            #warning("FIXME")
            fatalError()
        } label: {
            OperatorLabel(
                title: `operator`.title,
                subtitle: `operator`.subtitle,
                config: .iFora,
                iconView: Text("TBD Icon View")
            )
            .contentShape(Rectangle())
        }
    }
    
    private func failureView() -> some View {
        return FooterComponent.FooterView(
            state: .failure(.iFora),
            event: { events in event(.addCompany) },
            config: .iFora
        )
    }
    
    private func footerView(
        isExpanded: Bool
    ) -> some View {
        
        FooterComponent.FooterView(
            state: .footer(.iFora),
            event: { events in
                switch events {
                case .payByInstruction:
                    event(.payByInstruction)
                case .addCompany:
                    event(.addCompany)
                }
            },
            config: .iFora
        )
    }
    
    private func searchView(
    ) -> some View {
        
        TextField(
            "Search",
            text: .init(
                get: { state.searchText },
                set: {
                    // event(.composed(.utility(.search(.entered($0)))))
                    #warning("FIXME")
                    fatalError("\($0)")
                }
            )
        )
    }
}

#warning("move to the call site and make private")
/*private*/ extension UtilityPaymentLastPayment {
    
    var amount: String { subtitle }
}

private extension PrePaymentOptionsState {
    
    var uiState: UIState {
        
        guard !operators.isEmpty else { return .failure }
        
        return .options(self)
    }
    
    enum UIState {
        
        case failure
        case options(PrePaymentOptionsState)
    }
}

struct UtilityOperatorPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UtilityOperatorPicker(
            state: .init(lastPayments: [], operators: []),
            event: { _ in }
        )
    }
}

// MARK: - Static helpers

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterState.Footer {
        
    static let iFora: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию"
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterState.Failure {

    static let iFora: Self = .init(
        image: .init(systemName: "photo.artframe"),
        description: "Что-то пошло не так.\nПопробуйте позже."
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterView.Config {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .body,
            textColor: .black
        ),
        description: .init(
            textFont: .footnote,
            textColor: .gray.opacity(0.3)
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .gray.opacity(0.3)
        ),
        background: .gray,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(
            titleFont: .body,
            titleForeground: .white,
            backgroundColor: .blue
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .white,
            backgroundColor: .green
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension LastPaymentLabelConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .caption2,
            textColor: .red
        ),
        title: .init(
            textFont: .caption2,
            textColor: .gray
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension OperatorLabelConfig {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .headline,
            textColor: .black
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .gray
        )
    )
}
