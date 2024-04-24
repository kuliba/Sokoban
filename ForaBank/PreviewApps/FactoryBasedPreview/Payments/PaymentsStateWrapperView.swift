//
//  PaymentsStateWrapperView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import RxViewModel
import SwiftUI

struct PaymentsStateWrapperView: View {
    
    @StateObject private var viewModel: PaymentsViewModel
    
    private let config: Config
    
    init(
        viewModel: PaymentsViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    var body: some View {
        
        PaymentsView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: config
        )
    }
}

extension PaymentsStateWrapperView {
    
    typealias Config = PaymentsViewConfig
}

struct PaymentsStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview()
            preview(destination: .utilityServicePayment)
        }
    }
    
    static func preview(
        _ state: PaymentsState = .preview()
    ) -> some View {
        
        PaymentsStateWrapperView(
            viewModel: .preview(initialState: state),
            config: .preview
        )
    }
    
    static func preview(
        destination: PaymentsState.Destination
    ) -> some View {
        
        PaymentsStateWrapperView(
            viewModel: .preview(
                initialState: .preview(destination)
            ),
            config: .preview
        )
    }
}
