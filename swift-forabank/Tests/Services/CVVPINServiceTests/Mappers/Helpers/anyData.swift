//
//  anyData.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

import CryptoKit
import Foundation

func anyData(bitCount: Int = 256) -> Data {
    
    CryptoKit.SymmetricKey(size: .init(bitCount: bitCount))
        .withUnsafeBytes { Data($0) }
}
