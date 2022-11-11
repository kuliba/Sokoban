//
//  UInt64+Extention.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 27.10.2022.
//

import Foundation

extension UInt64 {
    
    static func seconds(_ value: Double) -> UInt64 {
        
        return UInt64(value * Double(NSEC_PER_SEC))
    }
}

