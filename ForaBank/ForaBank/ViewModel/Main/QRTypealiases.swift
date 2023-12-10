//
//  QRTypealiases.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel

typealias GetSberQRDataResult = Result<GetSberQRDataResponse, MappingRemoteServiceError<MappingError>>
typealias GetSberQRDataCompletion = (GetSberQRDataResult) -> Void
typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void

typealias CreateSberQRPayment = (CreateSberQRPaymentPayload, @escaping CreateSberQRPaymentCompletion) -> Void

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<MappingError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (URL, GetSberQRDataResponse, @escaping CreateSberQRPaymentCompletion) -> SberQRConfirmPaymentViewModel
