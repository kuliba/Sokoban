//
//  SberQRPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

final class SberQRPaymentViewModel: ObservableObject {
    
    typealias Commit = MakeSberQRPaymentCompletion
    
    let sberQRURL: URL
    let sberQRData: GetSberQRDataResponse
    let commit: Commit
    
    init(
        sberQRURL: URL,
        sberQRData: GetSberQRDataResponse,
        commit: @escaping Commit
    ) {
        self.sberQRURL = sberQRURL
        self.sberQRData = sberQRData
        self.commit = commit
    }
}
