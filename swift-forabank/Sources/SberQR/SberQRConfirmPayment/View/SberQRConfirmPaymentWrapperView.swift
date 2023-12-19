//
//  SberQRConfirmPaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

public struct SberQRConfirmPaymentWrapperView: View {

    public typealias Map = (GetSberQRDataResponse.Parameter.Info) -> Info
    
    @ObservedObject private var viewModel: SberQRConfirmPaymentViewModel
    
    private let map: Map
    private let config: Config
    
    public init(
        viewModel: SberQRConfirmPaymentViewModel,
        map: @escaping Map,
        config: Config
    ) {
        self.viewModel = viewModel
        self.map = map
        self.config = config
    }
    
    public var body: some View {
        
        SberQRConfirmPaymentView(
            state: .init(viewModel.state, map: map),
            event: viewModel.event(_:),
            config: config
        )
    }
}

private extension SberQRConfirmPaymentState {
    
    var amount: Decimal? {
        
        guard case let .editableAmount(editableAmount) = self
        else { return nil }
        
        return editableAmount.amount.value
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
        
        SberQRConfirmPaymentWrapperView(
            viewModel: .preview(
                initialState: initialState,
                pay: { print("pay!", String(describing: $0.amount), $0.product.type, $0.product.id) }
            ), 
            map: Info.preview,
            config: .default
        )
    }
}


private extension SberQRConfirmPaymentStateOf<Info> {
    
    init(
        _ state: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>,
        map: @escaping (GetSberQRDataResponse.Parameter.Info) -> Info
    ) {
        switch state {
        case let .editableAmount(editableAmount):
            self = .editableAmount(.init(editableAmount, map: map))
            
        case let .fixedAmount(fixedAmount):
            self = .fixedAmount(.init(fixedAmount, map: map))
        }
    }
}

private extension SberQRConfirmPaymentStateOf<Info>.EditableAmount {
    
    init(
        _ editableAmount: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>.EditableAmount,
        map: @escaping (GetSberQRDataResponse.Parameter.Info) -> Info
    ) {
        self.init(
            header: editableAmount.header,
            productSelect: editableAmount.productSelect,
            brandName: map(editableAmount.brandName),
            recipientBank: map(editableAmount.recipientBank),
            currency: editableAmount.currency,
            amount: editableAmount.amount
        )
    }
}

private extension SberQRConfirmPaymentStateOf<Info>.FixedAmount {
    
    init(
        _ fixedAmount: SberQRConfirmPaymentStateOf<GetSberQRDataResponse.Parameter.Info>.FixedAmount,
        map: @escaping (GetSberQRDataResponse.Parameter.Info) -> Info
    ) {
        self.init(
            header: fixedAmount.header,
            productSelect: fixedAmount.productSelect,
            brandName: map(fixedAmount.brandName),
            amount: map(fixedAmount.amount),
            recipientBank: map(fixedAmount.recipientBank),
            bottom: fixedAmount.bottom
        )
    }
}
