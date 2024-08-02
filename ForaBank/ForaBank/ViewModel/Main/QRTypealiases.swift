//
//  QRTypealiases.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import ForaTools
import Foundation
import SberQR

typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<MappingError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (GetSberQRDataResponse, @escaping (SberQRConfirmPaymentState) -> Void) throws -> SberQRConfirmPaymentViewModel

//typealias QRModel = QRModelWrapper<QRModelResult>
//typealias MakeQRScannerModel = () -> QRModel

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
        case provider(PaymentProvider)
        case single(QRCode, QRMapping)
        case source(Payments.Operation.Source)
        
        typealias MixedOperators = MultiElementArray<OperatorProvider<Operator, Provider>>
        typealias MultipleOperators = MultiElementArray<Operator>
        
        typealias Operator = OperatorGroupData.OperatorData
        typealias Provider = PaymentProvider
    }
}

//
//  PaymentProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProvider: Equatable {
    
    let id: String
    let type: PaymentProviderType
    
    enum PaymentProviderType: Equatable {
        
        case service
    }
}
