//
//  AppInfo.swift
//  ForaBank
//
//  Created by Дмитрий on 29.06.2022.
//

import Foundation

struct AppInfoLookupResult: Decodable {
    
    let results: [AppInfo]
}

struct AppInfo: Decodable {
    
    let version: String
    let trackViewUrl: String
}
