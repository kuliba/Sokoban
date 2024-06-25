//
//  AnywayTransactionStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

struct AnywayTransactionStateWrapperView<TransactionView>: View
where TransactionView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let makeTransactionView: MakeTransactionView
    
    init(
        viewModel: ViewModel,
        makeTransactionView: @escaping MakeTransactionView
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.makeTransactionView = makeTransactionView
    }
    
    var body: some View {

        makeTransactionView(viewModel.state, viewModel.event(_:))
            .spinnerDecorated(if: viewModel.isInflight)
    }
}

extension AnywayTransactionStateWrapperView {
    
    typealias ViewModel = AnywayTransactionViewModel
    typealias MakeTransactionView = (AnywayTransactionState, @escaping (AnywayTransactionEvent) -> Void) -> TransactionView
}

private extension View {
    
    @ViewBuilder
    func spinnerDecorated(
        if shouldShowSpinner: Bool
    ) -> some View {
        
        self
            .disabled(shouldShowSpinner)
            .opacity(shouldShowSpinner ? 0.8 : 1)
            .overlay(spinner(if: shouldShowSpinner))
    }
    
    @ViewBuilder
    private func spinner(if shouldShowSpinner: Bool) -> some View {
        
        if shouldShowSpinner {
            
            SpinnerRefreshView(icon: .init("Logo Fora Bank"))
        }
    }
}

private extension AnywayTransactionViewModel {
    
    var isInflight: Bool {
        
        state.transaction.status == .inflight
    }
}
