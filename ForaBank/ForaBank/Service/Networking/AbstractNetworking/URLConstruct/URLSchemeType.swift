//
//  URLSchemeType.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

/// Перечисление, члены которого определяют протоколы адреса

class URLSchemeType {
    
    enum URLScheme: String {
        case http = "http"
        case https = "https"
    }
}
