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
                    operators: state.operators,
                    latestPayments: state.lastPayments
                ),
                event: { event(.composed($0)) },
                lastPaymentView: lastPaymentView,
                operatorView: operatorView,
                footerView: footerView,
                searchView: searchView
            )
        }
    }
    
    private func lastPaymentView(
        latestPayment: OperatorsListComponents.LatestPayment
    ) -> some View {
        
        LatestPaymentView(
            latestPayment: latestPayment,
            event: { event(.composed(.selectLastOperation($0))) },
            config: .iFora
        )
    }
    
    private func operatorView(
        `operator`: OperatorsListComponents.Operator
    ) -> some View {
        
        OperatorView(
            operator: `operator`,
            event: { event(.composed(.selectOperator($0))) },
            config: .iFora
        )
    }
    
    private func failureView() -> some View {
        return FooterComponent.FooterView(
            state: .failure(.preview),
            event: { events in event(.addCompany) },
            config: .iFora
        )
    }
    
    private func footerView() -> some View {
        
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
    
    private func searchView() -> some View {
        
        TextField(
            "Search",
            text: .init(
                get: { state.searchText },
                set: { event(.composed(.utility(.search(.entered($0))))) }
            )
        )
    }
}

private extension PrePaymentOptionsState {
    
    var uiState: UIState {
        
        guard operators != nil else { return .failure }
        
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

private extension OperatorView.OperatorViewConfig {
    
    static let iFora: Self = .init(
        titleFont: .title3,
        titleColor: .black,
        descriptionFont: .footnote,
        descriptionColor: .gray,
        defaultIconBackgroundColor: .clear,
        defaultIcon: .init(systemName: "photo.artframe")
    )
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

private extension LatestPayment.LatestPaymentConfig {
    
    static let iFora: Self = .init(
        defaultImage: .init(systemName: "photo.artframe"),
        backgroundColor: .clear
    )
}
