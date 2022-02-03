//
//  ClientInfoResponseData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct ClientInfoData: Codable, Equatable {
    
    let address: String
    let firstName: String
    let lastName: String
    let patronymic: String?
    let regNumber: String
    let regSeries: String
}
