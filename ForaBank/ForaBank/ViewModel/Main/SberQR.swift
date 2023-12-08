//
//  SberQR.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
// QRScanner
typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel

typealias GetSberQRDataCompletion = (Result<Data, Error>) -> Void
typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void

typealias MakeSberQRPaymentCompletion = (Result<Data, Error>) -> Void
typealias MakeSberQRPaymentViewModel = (URL, Data, @escaping MakeSberQRPaymentCompletion) -> SberQRPaymentViewModel
