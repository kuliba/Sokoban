//
//  TransactionCompleteStatus.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

struct TransactionCompleteStatus: Equatable {
    
    let status: Status
    let formattedAmount: String
    let merchantLogo: Image?
    
    struct Status: Equatable {
        
        let logo: Image
        let title: String
        let subtitle: String?
    }
}
