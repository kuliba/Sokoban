//
//  CloseProductTransferData.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 15.11.2022.
//

import Foundation

struct CloseProductTransferData: Codable, Equatable {
    
    let paymentOperationDetailId: Int?
    let documentStatus: String
    let accountNumber: String?
    let closeDate: Int?
    let comment: String?
    let category: String?
}
