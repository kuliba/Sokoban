//
//  PaymentsTransfersViewModelFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersViewModelFactory {
    
    let makeUtilityPaymentViewModel: MakeUtilityPaymentViewModel
}

extension PaymentsTransfersViewModelFactory {
    
    typealias MakeUtilityPaymentViewModelCompletion = (UtilityPaymentViewModel) -> Void
    typealias MakeUtilityPaymentViewModel = (@escaping MakeUtilityPaymentViewModelCompletion) -> Void
}
