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

struct ComposedOperatorsWrapperView: View {
    
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var viewModel: UtilityPaymentsViewModel = .preview(initialState: .init())
 
    let selectLast: (LatestPayment.ID) -> Void
    let selectOperator: (OperatorsListComponents.Operator.ID) -> Void
    
    var body: some View {
        
        ComposedOperatorsView(
            state: .init(
                operators: viewModel.state.operators,
                latestPayments: viewModel.state.lastPayments
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
                    descriptionColor: .gray,
                    defaultIconBackgroundColor: .yellow,
                    defaultIcon: .init(systemName: "photo.artframe")
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
        
        ComposedOperatorsWrapperView(
            searchViewModel: searchViewModel,
            selectLast: { _ in },
            selectOperator: { _ in }
        )
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

private extension ComposedOperatorsWrapperView {
    
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
