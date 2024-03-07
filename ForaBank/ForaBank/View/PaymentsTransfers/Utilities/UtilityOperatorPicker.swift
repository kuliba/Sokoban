//
//  UtilityOperatorPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import OperatorsListComponents
import SwiftUI

struct UtilityOperatorPicker: View {
    
    let state: UtilitiesViewModel.State
    let event: (UtilityPaymentEvent) -> Void
    
    var body: some View {
        
        if state.operators != nil {
            
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
            
        } else {
            
            Text("TBD: Footer View with pay by Instruction button")
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
    
    private func footerView() -> some View {
        
        OperatorsListComponents.NoCompanyInListView(
            noCompanyListViewModel: .default(
                payByInstruction: { event(.payByInstruction) },
                addCompany: { event(.addCompany) }
            ),
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

private extension OperatorsListComponents.NoCompanyInListViewModel {
    
    static func `default`(
        payByInstruction: @escaping () -> Void,
        addCompany: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Нет компании в списке?",
            description: "Воспользуйтесь другими способами оплаты",
            subtitle: "Сообщите нам, и мы подключим новую организацию",
            buttons: [
                .init(
                    title: "Оплатить по реквизитам",
                    buttonConfiguration: .init(
                        titleFont: .body,
                        titleForeground: .red,
                        backgroundColor: .gray
                    ),
                    action: payByInstruction
                ),
                .init(
                    title: "Добавить организацию",
                    buttonConfiguration: .init(
                        titleFont: .body,
                        titleForeground: .blue,
                        backgroundColor: .gray
                    ),
                    action: addCompany
                )
            ]
        )
    }
}

private extension NoCompanyInListViewConfig {
    
    static let iFora: Self = .init(
        titleFont: .title,
        titleColor: .black,
        descriptionFont: .callout,
        descriptionColor: .gray,
        subtitleFont: .footnote,
        subtitleColor: .gray
    )
}

private extension LatestPayment.LatestPaymentConfig {
    
    static let iFora: Self = .init(
        defaultImage: .init(systemName: "photo.artframe"),
        backgroundColor: .clear
    )
}
