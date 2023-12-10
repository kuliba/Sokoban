//
//  SberQRConfirmPaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

public struct SberQRConfirmPaymentWrapperView: View {
    
    @ObservedObject private var viewModel: SberQRConfirmPaymentViewModel
    
    public init(viewModel: SberQRConfirmPaymentViewModel) {
        
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        SberQRConfirmPaymentView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            wrapper(initialState: .fixedAmount(.preview))
            wrapper(initialState: .editableAmount(.preview))
        }
    }
    
    private static func wrapper(
        initialState: SberQRConfirmPaymentState
    ) -> some View {
        
        SberQRConfirmPaymentWrapperView(viewModel: .preview(
            initialState: initialState,
            pay: { print("pay!", String(describing: $0.amount), $0.product.type, $0.product.id) }
        ))
    }
}

private extension SberQRConfirmPaymentState {
    
    var amount: Decimal? {
        
        guard case let .editableAmount(editableAmount) = self 
        else { return nil }

        return editableAmount.bottom.value
    }
    
    var product: ProductSelect.Product {
        
        switch self {
        case let .editableAmount(editableAmount):
            return editableAmount.productSelect.product
        
        case let .fixedAmount(fixedAmount):
            return fixedAmount.productSelect.product
        }
    }
}

private extension ProductSelect {
    
    var product: ProductSelect.Product {
        
        switch self {
        case let .compact(product):
            return product
            
        case let .expanded(product, _):
            return product
        }
    }
}
