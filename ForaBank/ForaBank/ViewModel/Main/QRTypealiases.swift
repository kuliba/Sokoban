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

typealias QRModel = QRModelWrapper<QRViewModel.ScanResult>//<QRModelResult>
typealias MakeQRScannerModel = () -> QRModel

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
        
        case mixed(MixedOperators, QRCode)
        case multiple(MultipleOperators, QRCode)
        case none(QRCode)
        case provider(Provider, QRCode)
        case single(QRCode, QRMapping)
        case source(Payments.Operation.Source)
        
        typealias MixedOperators = MultiElementArray<OperatorProvider<Operator, Provider>>
        typealias MultipleOperators = MultiElementArray<Operator>
        
        typealias Operator = SegmentedOperatorData
        typealias Provider = SegmentedProvider
    }
}
