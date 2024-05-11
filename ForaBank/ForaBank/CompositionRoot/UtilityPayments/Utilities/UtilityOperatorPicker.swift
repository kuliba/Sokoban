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

struct UtilityOperatorPicker: View {
    
    let state: UtilitiesViewModel.State
    let event: (UtilityPaymentEvent) -> Void
    
    var body: some View {
        
        switch state.uiState {
            
        case . failure:
            failureView()
            
        case let .options(state):
            ComposedOperatorsView(
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
    
#warning("fix `makeIconView`")
    private func lastPaymentView(
        latestPayment: OperatorsListComponents.LastPayment
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
                iconView: Text("TBD Icon View \(latestPayment)")
            )
            .contentShape(Rectangle())
        }
    }
    
    typealias Operator = OperatorsListComponents.Operator<String>
    
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
                iconView: Text("TBD Icon View \(`operator`)")
            )
            .contentShape(Rectangle())
        }
    }
    
    private func failureView() -> some View {
        return FooterComponent.FooterView(
            state: .failure(.preview),
            event: { events in event(.addCompany) },
            config: .iFora
        )
    }
    
    private func footerView(
        isExpanded: Bool
    ) -> some View {
        
        FooterComponent.FooterView(
            state: .footer(.preview),
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
        _ searchText: String
    ) -> some View {
        
        TextField(
            "Search",
            text: .init(
                get: { searchText },
                set: {
                    // event(.composed(.utility(.search(.entered($0)))))
                    #warning("FIXME")
                    fatalError("\($0)")
                }
            )
        )
    }
}

private extension OperatorsListComponents.LastPayment {
    
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

private extension FooterComponent.FooterState.Footer {
        
    static let preview: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию"
    )
}

private extension FooterComponent.FooterState.Failure {

    static let preview: Self = .init(
        image: .init(systemName: "photo.artframe"),
        description: "Что-то пошло не так.\nПопробуйте позже."
    )
}

private extension FooterComponent.FooterView.Config {
    
    static let iFora: Self = .init(
        titleConfig: .init(textFont: .title3, textColor: .black),
        descriptionConfig: .init(textFont: .body, textColor: .gray.opacity(0.3)),
        subtitleConfig: .init(textFont: .body, textColor: .gray.opacity(0.3)),
        backgroundIcon: .gray,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(
            titleFont: .body,
            titleForeground: .red,
            backgroundColor: .gray
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .blue,
            backgroundColor: .gray
        )
    )
}

private extension LastPaymentLabelConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .title3,
            textColor: .black
        ),
        title: .init(
            textFont: .footnote,
            textColor: .gray
        )
    )
}

private extension OperatorLabelConfig {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .title3,
            textColor: .black
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .gray
        )
    )
}
