//
//  anySerial.swift
//
//
//  Created by Valentin Ozerov on 11.10.2024.
//

import Foundation
import CryptoKit

func anySerial() -> String {
    MD5(string: UUID().uuidString)
}

private func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))

    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}
