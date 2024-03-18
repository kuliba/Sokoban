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
import PrePaymentPicker
import TextFieldComponent

typealias SearchViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

struct ComposedOperatorsWrapperView: View {
    
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var viewModel: PrePaymentOptionsViewModel = .preview(initialState: .init())
 
    let selectLast: (LatestPayment.ID) -> Void
    let selectOperator: (OperatorsListComponents.Operator.ID) -> Void
    
    let configView: ConfigView
    
    init(
        searchViewModel: SearchViewModel,
        viewModel: PrePaymentOptionsViewModel,
        selectLast: @escaping (LatestPayment.ID) -> Void,
        selectOperator: @escaping (OperatorsListComponents.Operator.ID) -> Void,
        configView: ConfigView
    ) {
        self.selectLast = selectLast
        self.selectOperator = selectOperator
        self.configView = configView
        
        let regularFieldViewModel: RegularFieldViewModel = .make(
            keyboardType: .default,
            text: nil,
            placeholderText: "Наименование или ИНН",
            limit: 210
        )
        
        self._searchViewModel = .init(
            wrappedValue: regularFieldViewModel
        )
    }
    
    var body: some View {
        
        ComposedOperatorsView(
            state: .init(
                operators: viewModel.state.filteredOperators,
                latestPayments: viewModel.state.searchText.isEmpty ? viewModel.state.lastPayments : []
            ),
            event: event(_:),
            lastPaymentView: { payment in
                
                LatestPaymentView(
                    latestPayment: payment,
                    latestPaymentConfigView: configView.latestConfig,
                    event: { _ in }
                )
            },
            operatorView: { `operator` in OperatorView(
                operator: `operator`,
                event: { _ in },
                config: .init(
                    titleFont: .title3,
                    titleColor: .black,
                    descriptionFont: .footnote,
                    descriptionColor: .gray,
                    defaultIconBackgroundColor: .clear,
                    defaultIcon: .init(systemName: "photo.artframe")
                )
            )
            .monospacedDigit()  
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
                .onChange(of: searchViewModel.state, {
                    
                    if case let .editing(state) = searchViewModel.state {
                        event(.utility(.search(.entered(state.text))))
                    }
                })
            }
        )
    }
}

struct ConfigView {
    
    let latestConfig: LatestPayment.LatestPaymentConfig
}

struct ContentView: View {
    
    @StateObject var searchViewModel: SearchViewModel

    var body: some View {
        
        ComposedOperatorsWrapperView(
            searchViewModel: searchViewModel,
            viewModel: .preview(initialState: .init()),
            selectLast: { _ in },
            selectOperator: { _ in },
            configView: .init(
                latestConfig: .init(
                    defaultImage: .init(systemName: "photo.artframe"),
                    backgroundColor: .clear
                ))
        )
        .edgesIgnoringSafeArea(.bottom)
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
