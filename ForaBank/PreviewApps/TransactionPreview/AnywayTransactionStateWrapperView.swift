//
//  AnywayTransactionStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct AnywayTransactionStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let factory: AnywayTransactionView.Factory
    
    init(
        viewModel: ViewModel,
        factory: AnywayTransactionView.Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        AnywayTransactionView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory
        )
        .onChange(of: viewModel.state) { dump($0) }
    }
}

extension AnywayTransactionStateWrapperView {
    
    typealias ViewModel = ObservingAnywayTransactionViewModel
}

#Preview {
    AnywayTransactionStateWrapperView(viewModel: .preview(), factory: .preview)
}
