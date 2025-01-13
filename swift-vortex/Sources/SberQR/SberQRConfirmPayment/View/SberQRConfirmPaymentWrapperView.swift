//
//  SberQRConfirmPaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents
import SwiftUI

public struct SberQRConfirmPaymentWrapperView: View {

    public typealias Map = (GetSberQRDataResponse.Parameter.Info) -> PublishingInfo
    
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
            state: .init(viewModel.state.confirm, map: map),
            event: viewModel.event(_:),
            config: config
        )
    }
}

private extension SberQRConfirmPaymentState {
    
    var amount: Decimal? {
        
        guard case let .editableAmount(editableAmount) = confirm
        else { return nil }
        
        return editableAmount.amount.value
    }
    
    var product: ProductSelect.Product? {
        
        switch confirm {
        case let .editableAmount(editableAmount):
            return editableAmount.productSelect.selected
            
        case let .fixedAmount(fixedAmount):
            return fixedAmount.productSelect.selected
        }
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            wrapper(initialState: .init(confirm: .fixedAmount(.preview)))
            wrapper(initialState: .init(confirm: .editableAmount(.preview)))
        }
    }
    
    private static func wrapper(
        initialState: SberQRConfirmPaymentState
    ) -> some View {
        
        SberQRConfirmPaymentWrapperView(
            viewModel: .preview(
                initialState: initialState,
                pay: {
                    if let product = $0.product {
                        
                        print("pay!", String(describing: $0.amount), product.type, product.id)
                    } else {
                        
                        print("product is nil")
                    }
                }
            ),
            map: PublishingInfo.preview,
            config: .preview
        )
    }
}


private extension SberQRConfirmPaymentStateOf<PublishingInfo> {
    
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

private extension EditableAmount<PublishingInfo> {
    
    init(
        _ editableAmount: EditableAmount<GetSberQRDataResponse.Parameter.Info>,
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

private extension FixedAmount<PublishingInfo> {
    
    init(
        _ fixedAmount: FixedAmount<GetSberQRDataResponse.Parameter.Info>,
        map: @escaping (GetSberQRDataResponse.Parameter.Info) -> Info
    ) {
        self.init(
            header: fixedAmount.header,
            productSelect: fixedAmount.productSelect,
            brandName: map(fixedAmount.brandName),
            amount: map(fixedAmount.amount),
            recipientBank: map(fixedAmount.recipientBank),
            button: fixedAmount.button
        )
    }
}
