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

typealias MakeSberQRPaymentResult = (Result<Data, Error>)
typealias MakeSberQRPaymentCompletion = (MakeSberQRPaymentResult) -> Void
typealias MakeSberQRPaymentViewModel = (URL, GetSberQRDataResponse, @escaping MakeSberQRPaymentCompletion) -> SberQRPaymentViewModel
