//
//  QRTypealiases.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import ForaTools
import Foundation
import SberQR

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<MappingError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (GetSberQRDataResponse, @escaping (SberQRConfirmPaymentState) -> Void) throws -> SberQRConfirmPaymentViewModel

typealias QRModel = QRModelWrapper<QRModelResult>
typealias MakeQRScannerModel = () -> QRModel

typealias SegmentedOperatorProvider = OperatorProvider<SegmentedOperatorData, SegmentedProvider>

typealias SegmentedOperatorData = SegmentedOperator<OperatorGroupData.OperatorData, String>
typealias SegmentedProvider = SegmentedOperator<UtilityPaymentProvider, String>

enum QRModelResult: Equatable {
    
    case c2bSubscribeURL(URL)
    case c2bURL(URL)
    case failure(QRCode)
    case mapped(Mapped)
    case sberQR(URL)
    case url(URL)
    case unknown
    
    enum Mapped: Equatable {
        
        case mixed(MixedOperators, QRCode, QRMapping)
        case multiple(MultipleOperators, QRCode, QRMapping)
        case none(QRCode)
        case provider(PaymentProviderServicePickerPayload)
        case single(Operator, QRCode, QRMapping)
        case source(Payments.Operation.Source)
        
        typealias MixedOperators = MultiElementArray<SegmentedOperatorProvider>
        typealias MultipleOperators = MultiElementArray<Operator>
        
        typealias Operator = SegmentedOperatorData
        typealias Provider = SegmentedProvider
    }
}
