//
//  AnywayTransactionStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

struct AnywayTransactionStateWrapperView<TransactionView>: View
where TransactionView: View {
    
    @StateObject private var viewModel: ViewModel
    
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
    }
}

extension AnywayTransactionStateWrapperView {
    
    typealias ViewModel = ObservingCachedAnywayTransactionViewModel
    typealias MakeTransactionView = (CachedTransactionState, @escaping (CachedTransactionEvent) -> Void) -> TransactionView
}
