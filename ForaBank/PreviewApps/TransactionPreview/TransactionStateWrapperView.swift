//
//  TransactionStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct TransactionStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        TransactionView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
    }
}

extension TransactionStateWrapperView {
    
    typealias ViewModel = TransactionViewModel
}

#Preview {
    TransactionStateWrapperView(viewModel: .preview())
}
