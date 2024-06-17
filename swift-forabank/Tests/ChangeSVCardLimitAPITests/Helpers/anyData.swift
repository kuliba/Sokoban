//
//  anyData.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import CryptoKit
import Foundation

func anyData(bitCount: Int = 256) -> Data {
    
    let key = SymmetricKey(size: .init(bitCount: bitCount))
    
    return key.withUnsafeBytes { Data($0) }
}
