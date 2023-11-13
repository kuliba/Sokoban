//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import CryptoKit
import Foundation
import TransferPublicKey

func anySharedSecret<OTP>(
    bitCount: Int = 64
) -> SwaddleKeyDomain<OTP>.SharedSecret {
    
    .init(anyData(bitCount: 64))
}

func anyHTTPURLResponse(
    with statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURL(
    string: String = "any.url"
) -> URL {
    
    .init(string: string)!
}

func anyError(
    _ domain: String = "any error",
    _ code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}

func anyData(bitCount: Int = 64) -> Data {
    
    let key = SymmetricKey(size: .init(bitCount: bitCount))
    
    return key.withUnsafeBytes { Data($0) }
}
