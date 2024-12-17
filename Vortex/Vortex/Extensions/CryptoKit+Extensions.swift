//
//  CryptoKit+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 26.04.2022.
//

import Foundation
import CryptoKit

extension Digest {
    
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    var hexStr: String { bytes.map { String(format: "%02X", $0) }.joined() }
}
