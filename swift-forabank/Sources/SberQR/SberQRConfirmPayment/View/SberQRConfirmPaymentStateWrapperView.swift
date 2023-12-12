//
//  SberQRConfirmPaymentStateWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct SberQRConfirmPaymentStateWrapperView: View {
    
    @StateObject private var viewModel: SberQRConfirmPaymentViewModel
    
    private let config: Config
    
    init(
        viewModel: SberQRConfirmPaymentViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    var body: some View {
        
        SberQRConfirmPaymentWrapperView(
            viewModel: viewModel,
            config: config
        )
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            SberQRConfirmPaymentStateWrapperView(
                viewModel: .preview(
                    initialState: .fixedAmount(.preview)
                ),
                config: .default
            )
            
            SberQRConfirmPaymentStateWrapperView(
                viewModel: .preview(
                    initialState: .editableAmount(.preview)
                ),
                config: .default
            )
        }
    }
}
