//
//  StatementFormat.swift
//  ForaBank
//
//  Created by Дмитрий on 21.01.2022.
//

import Foundation

enum StatementFormat: String, Codable, Unknownable {

    case csv = "CSV"
    case pdf = "PDF"
    case unknown
}
