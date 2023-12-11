//
//  QRTypealiases.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<MappingError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (URL, GetSberQRDataResponse, @escaping CreateSberQRPaymentCompletion, @escaping (SberQRConfirmPaymentState) -> Void) throws -> SberQRConfirmPaymentViewModel
