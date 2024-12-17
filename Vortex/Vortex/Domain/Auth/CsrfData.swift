//
//  CsrfData.swift
//  ForaBank
//
//  Created by Дмитрий on 19.01.2022.
//

import Foundation
import CoreText

struct CsrfData: Codable, Equatable {
    
    let cert: String
    let headerName: String
    let pk: String
    let sign: String
    let token: String
}
