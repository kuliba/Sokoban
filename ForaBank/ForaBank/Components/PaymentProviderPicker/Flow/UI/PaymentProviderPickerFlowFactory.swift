//
//  PaymentProviderPickerFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct PaymentProviderPickerFlowFactory {
    
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
}

extension PaymentProviderPickerFlowFactory {
    
   typealias MakePayByInstructionsViewModel = (QRCode, @escaping () -> Void) -> PaymentsViewModel
}
