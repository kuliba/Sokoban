//
//  UserSettingData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct UserSettingData: Codable, Equatable {
    
    let name: String
    let sysName: String
    let value: String
}
