//
//  PaymentsTransfersViewModelFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersViewModelFactory {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
}

extension PaymentsTransfersViewModelFactory {
    
    typealias MakeUtilityPrepaymentViewModelCompletion = (UtilityPrepaymentViewModel) -> Void
    typealias MakeUtilityPrepaymentViewModel = (@escaping MakeUtilityPrepaymentViewModelCompletion) -> Void
}
