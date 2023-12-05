//
//  SberQRPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation

final class SberQRPaymentViewModel: ObservableObject {
    
    let sberQRURL: URL
    let sberQRData: Data
    
    init(
        sberQRURL: URL,
        sberQRData: Data
    ) {    
        self.sberQRURL = sberQRURL
        self.sberQRData = sberQRData
    }
}
