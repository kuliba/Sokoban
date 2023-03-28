//
//  AnywayOperatorsData.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 31.01.2023.
//

import Foundation

struct AnywayOperator: Codable, Equatable {
    
    let id: String
    let name: String
    let subname: String?
    let timeWork: String?
    let codeValut: String?
    let codeParent: String
    let md5hash: String?
}
