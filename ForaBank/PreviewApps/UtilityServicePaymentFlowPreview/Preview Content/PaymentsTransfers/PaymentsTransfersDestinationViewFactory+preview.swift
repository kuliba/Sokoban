//
//  PaymentsTransfersDestinationViewFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

extension PaymentsTransfersDestinationViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeUtilityPrepaymentView: {
                
                .init(viewModel: $0, flowEvent: { print($0) }, config: .preview)
            }
        )
    }
}
