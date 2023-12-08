//
//  SberQRConfirmPaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct SberQRConfirmPaymentWrapperView: View {
    
    @ObservedObject private var viewModel: SberQRConfirmPaymentViewModel
    
    init(viewModel: SberQRConfirmPaymentViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        SberQRConfirmPaymentView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
        .animation(.easeInOut(duration: 1), value: viewModel.state)
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            SberQRConfirmPaymentWrapperView(viewModel: .preview(
                initialState: .fixedAmount(.preview)
            ))
            
            SberQRConfirmPaymentWrapperView(viewModel: .preview(
                initialState: .editableAmount(.preview)
            ))
        }
    }
}
