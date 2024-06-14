//
//  SelectWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import PaymentComponents
import SwiftUI

struct SelectWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
        
    init(viewModel: ViewModel) {

        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        SelectView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora
        )
    }
}

extension SelectWrapperView {
    
    typealias ViewModel = ObservingSelectViewModel
}
