//
//  SberQRPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation

final class SberQRPaymentViewModel: ObservableObject {
    
    let sberQRData: Data
    
    init(_ sberQRData: Data) {
        
        self.sberQRData = sberQRData
    }
}
