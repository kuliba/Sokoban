//
//  SegmentedPaymentProviderPickerFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct SegmentedPaymentProviderPickerFlowFactory {
    
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
    let makePaymentsViewModel: MakePaymentsViewModel
    let makeServicePickerFlowModel: MakeServicePickerFlowModel
}

extension SegmentedPaymentProviderPickerFlowFactory {
    
    typealias MakePayByInstructionsViewModel = (QRCode, @escaping () -> Void) -> PaymentsViewModel
    
    typealias MakePaymentsViewModel = (Operator, QRCode, @escaping () -> Void) -> PaymentsViewModel
    typealias Operator = SegmentedOperatorData
    
    typealias MakeServicePickerFlowModel = (PaymentProviderServicePickerPayload) -> AnywayServicePickerFlowModel
    typealias Provider = SegmentedProvider
}
