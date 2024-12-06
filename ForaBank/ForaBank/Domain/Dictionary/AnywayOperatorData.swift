//
//  AnywayOperatorData.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 31.01.2023.
//

import Foundation

struct AnywayOperatorData: Codable, Equatable {
    
    let id: String
    let name: String
    let subname: String?
    let timeWork: String?
    let codeValut: String?
    let codeParent: String
    let md5hash: String?
}
