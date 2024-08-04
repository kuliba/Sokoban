//
//  PaymentProviderPickerFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct PaymentProviderPickerFlowFactory {
    
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
    let makePaymentsViewModel: MakePaymentsViewModel
    let makeServicePickerFlowModel: MakeServicePickerFlowModel
}

extension PaymentProviderPickerFlowFactory {
    
    typealias MakePayByInstructionsViewModel = (QRCode, @escaping () -> Void) -> PaymentsViewModel
    
    typealias MakePaymentsViewModel = (Operator, QRCode, @escaping () -> Void) -> PaymentsViewModel
    typealias Operator = SegmentedOperatorData
    
    typealias MakeServicePickerFlowModel = (Provider) -> AnywayServicePickerFlowModel
    typealias Provider = SegmentedProvider
}
