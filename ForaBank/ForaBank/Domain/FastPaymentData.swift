//
//  FastPayment.swift
//  ForaBank
//
//  Created by Max Gribov on 28.12.2021.
//

import Foundation

//FIXME: Statements API documentation required
struct FastPaymentData: Codable {
    
    let documentComment: String?
    let foreignBankBIC: String?
    let foreignBankID: String?
    let foreignBankName: String?
    let foreignName: String?
    let foreignPhoneNumber: String?
    let opkcid: String?
}
