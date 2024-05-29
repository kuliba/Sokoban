//
//  AnywayTransactionStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
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
            .onChange(of: viewModel.state) { dump($0) }
    }
}

extension AnywayTransactionStateWrapperView {
    
    typealias ViewModel = ObservingAnywayTransactionViewModel
    typealias MakeTransactionView = (AnywayTransactionState, @escaping (AnywayTransactionEvent) -> Void) -> TransactionView
}

#Preview {
    AnywayTransactionStateWrapperView(viewModel: .preview()) { _,_ in Text("WrapperView") }
}
