//
//  DataExtension.swift
//  ForaBank
//
//  Created by Дмитрий on 27.07.2021.
//

import Foundation

extension Data {
    
    /// Hexadecimal string representation of `Data` object.
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
