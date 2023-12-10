//
//  QRTypealiases.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel

typealias GetSberQRDataResult = Result<GetSberQRDataResponse, MappingRemoteServiceError<GetSberQRDataError>>
typealias GetSberQRDataCompletion = (GetSberQRDataResult) -> Void
typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void

typealias CreateSberQRPayment = (CreateSberQRPaymentPayload, @escaping CreateSberQRPaymentCompletion) -> Void

#warning("STUB!!")
typealias CreateSberQRPaymentResponse = Data
typealias CreateSberQRPaymentError = Error

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<CreateSberQRPaymentError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (URL, GetSberQRDataResponse, @escaping CreateSberQRPaymentCompletion) -> SberQRConfirmPaymentViewModel
