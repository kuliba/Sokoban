//
//  SberQRConfirmPaymentStateWrapperView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct SberQRConfirmPaymentStateWrapperView: View {
    
    @StateObject private var viewModel: SberQRConfirmPaymentViewModel
    
    init(viewModel: SberQRConfirmPaymentViewModel) {
     
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        SberQRConfirmPaymentWrapperView(viewModel: viewModel)
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            SberQRConfirmPaymentStateWrapperView(viewModel: .preview(
                initialState: .fixedAmount(.preview)
            ))
            
            SberQRConfirmPaymentStateWrapperView(viewModel: .preview(
                initialState: .editableAmount(.preview)
            ))
        }
    }
}
