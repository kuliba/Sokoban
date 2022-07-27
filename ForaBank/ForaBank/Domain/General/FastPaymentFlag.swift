//
//  FastPaymentFlag.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

enum FastPaymentFlag: String, Codable, Unknownable {
    
    case empty = "EMPTY"
    case no = "NO"
    case yes = "YES"
    case unknown
}
