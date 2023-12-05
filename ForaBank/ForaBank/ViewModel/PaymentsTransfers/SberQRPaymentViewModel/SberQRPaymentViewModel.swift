//
//  SberQRPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation

final class SberQRPaymentViewModel: ObservableObject {
    
    typealias Commit = MakeSberQRPaymentCompletion
    
    let sberQRURL: URL
    let sberQRData: Data
    let commit: Commit
    
    init(
        sberQRURL: URL,
        sberQRData: Data,
        commit: @escaping Commit
    ) {
        self.sberQRURL = sberQRURL
        self.sberQRData = sberQRData
        self.commit = commit
    }
}
