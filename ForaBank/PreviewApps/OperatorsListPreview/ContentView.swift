//
//  ContentView.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import SwiftUI
import OperatorsListComponents
import SearchBarComponent
import TextFieldUI
import TextFieldComponent
import UtilityPaymentsRx

typealias SearchViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

private extension OperatorsListComponents.Operator {
    
    init(_ operator: UtilityPaymentsRx.Operator) {
        fatalError()
    }
}

private extension OperatorsListComponents.LatestPayment {

    init(_ latestPayment: UtilityPaymentsRx.LastPayment) {
        fatalError()
    }
}

private extension UtilityPaymentsViewModel {
    
    var operators: [OperatorsListComponents.Operator] {
        guard let operators = state.operators else {
            return [] //FIX: remove empty unwrapp
        }
        
        return operators.map(OperatorsListComponents.Operator.init)
    }
    var lastPayments: [OperatorsListComponents.LatestPayment] {
        
        guard let latestPayments = state.lastPayments else {
            return [] //FIX: remove empty unwrapp
        }
        
        return latestPayments.map(OperatorsListComponents.LatestPayment.init)
    }
}

struct ComposedOperatorsWrapperView: View {
    
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var viewModel: UtilityPaymentsViewModel = .preview(initialState: .init())
 
    let selectLast: (LatestPayment.ID) -> Void
    let selectOperator: (OperatorsListComponents.Operator.ID) -> Void
    
    func event(_ event: ComposedOperatorsEvent) {
    
        switch event {
        case let .selectLastOperation(id):
            selectLast(id)
            
        case let .selectOperator(id):
            selectOperator(id)
            
        case let .utility(event):
            viewModel.event(event)
        }
    }
    
    var body: some View {
        
        ComposedOperatorsView(
            state: .init(
                operators: viewModel.operators,
                latestPayments: viewModel.lastPayments
            ),
            event: event(_:),
            lastPaymentView: { payment in
                
                LatestPaymentView(
                    latestPayment: payment,
                    event: { _ in }
                )
            },
            operatorView: { `operator` in OperatorView(
                operator: `operator`,
                config: .init(
                    titleFont: .title3,
                    titleColor: .black,
                    descriptionFont: .footnote,
                    descriptionColor: .gray
                ))
            },
            footerView: { NoCompanyInListView(
                noCompanyListViewModel: .sample,
                config: .init(
                    titleFont: .title,
                    titleColor: .black,
                    descriptionFont: .callout,
                    descriptionColor: .gray,
                    subtitleFont: .footnote,
                    subtitleColor: .gray
                )) },
            searchView: {
                CancellableSearchBarView(
                    viewModel: searchViewModel,
                    textFieldConfig: .sample,
                    clearButtonLabel: { Image(systemName: "xmark") },
                    cancelButton: { Button("Cancel", action: {}) }
                )
            }
        )
    }
}

struct ContentView: View {
    
    let searchViewModel: SearchViewModel

    var body: some View {
        
        ComposedOperatorsView(
            state: .init(
                operators: mockOperators(),
                latestPayments: mockLatestPayment()
            ),
            event: { _ in },
            lastPaymentView: { payment in
                
                LatestPaymentView(
                    latestPayment: payment,
                    event: { _ in }
                )
            },
            operatorView: { `operator` in OperatorView(
                operator: `operator`,
                config: .init(
                    titleFont: .title3,
                    titleColor: .black,
                    descriptionFont: .footnote,
                    descriptionColor: .gray
                ))
            },
            footerView: { NoCompanyInListView(
                noCompanyListViewModel: .sample,
                config: .init(
                    titleFont: .title,
                    titleColor: .black,
                    descriptionFont: .callout,
                    descriptionColor: .gray,
                    subtitleFont: .footnote,
                    subtitleColor: .gray
                )) },
            searchView: {
                CancellableSearchBarView(
                    viewModel: searchViewModel,
                    textFieldConfig: .sample,
                    clearButtonLabel: { Image(systemName: "xmark") },
                    cancelButton: { Button("Cancel", action: {}) }
                )
            }
        )
    }
}

private extension ContentView {
    
    func mockLatestPayment() -> [LatestPayment] {
    
        [
            .init(
                image: .init(systemName: "photo.artframe"),
                title: "ЖКУ Москвы (ЕИРЦ)",
                amount: "100 ₽"
            ),
            .init(
                image: .init(systemName: "photo.artframe"),
                title: "МОСОБЛГАЗ",
                amount: "1 780 ₽"
            ),
            .init(
                image: .init(systemName: "photo.artframe"),
                title: "ЖКУ Краснодара",
                amount: "1 680 ₽"
            )
        ]
    }
    
    func mockOperators() -> [OperatorsListComponents.Operator] {
        
        [.init(
            id: "1",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
         .init(
            id: "2",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "3",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "4",
            title: "ЖКУ Краснодара",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "5",
            title: "ГАЗПРОМ МЕЖРЕГИОН ГАЗ ЯРОСЛАВЛЬ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "6",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "7",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "8",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "9",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "10",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         ),
         .init(
            id: "11",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
         )
        ]
    }
}

private extension TextFieldView.TextFieldConfig {
    
    static let sample: Self = .init(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        tintColor: .red,
        backgroundColor: .clear,
        placeholderColor: .pink
    )
}

#Preview {
    ContentView(searchViewModel: .init(
        initialState: .placeholder("Search subscriptions"),
        reducer: TransformingReducer(
            placeholderText: "Search subscriptions"
        ),
        keyboardType: .decimal
    ))
}
