//
//  AnywayTransactionStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct AnywayTransactionStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        AnywayTransactionView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
        .onChange(of: viewModel.state) { dump($0) }
    }
}

extension AnywayTransactionStateWrapperView {
    
    typealias ViewModel = AnywayTransactionViewModel
}

#Preview {
    AnywayTransactionStateWrapperView(viewModel: .preview())
}
