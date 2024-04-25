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
    
    private let factory: Factory
    
    init(
        viewModel: PaymentsViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        PaymentsView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory
        )
    }
}

extension PaymentsStateWrapperView {
    
    typealias Factory = PaymentsViewFactory
}

struct PaymentsStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview()
            preview(destination: .paymentFlow(.utilityServicePayment))
        }
    }
    
    static func preview(
        _ state: PaymentsState = .preview()
    ) -> some View {
        
        NavigationView {
            
            PaymentsStateWrapperView(
                viewModel: .preview(initialState: state),
                factory: .preview
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    static func preview(
        destination: PaymentsState.Destination
    ) -> some View {
        
        NavigationView {
            
            PaymentsStateWrapperView(
                viewModel: .preview(
                    initialState: .preview(destination)
                ),
                factory: .preview
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
