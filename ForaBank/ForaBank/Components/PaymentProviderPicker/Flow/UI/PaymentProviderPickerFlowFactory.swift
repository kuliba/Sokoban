//
//  PaymentProviderPickerFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct PaymentProviderPickerFlowFactory {
    
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
    let makePaymentsViewModel: MakePaymentsViewModel
}

extension PaymentProviderPickerFlowFactory {
    
   typealias MakePayByInstructionsViewModel = (QRCode, @escaping () -> Void) -> PaymentsViewModel
   typealias MakePaymentsViewModel = (Operator, @escaping () -> Void) -> PaymentsViewModel
    typealias Operator = SegmentedOperatorData
}
