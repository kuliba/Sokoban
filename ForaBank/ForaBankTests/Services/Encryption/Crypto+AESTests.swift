//
//  Crypto+AESTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.08.2023.
//

@testable import ForaBank
import XCTest

//final class Crypto_AESTests: XCTestCase {
//    
//    func test_serverPublicKeyEncryptedString_decryption_AES_GCM() throws {
//        
//        let (publicTransportKeyData, publicKeyEncryptedData) = try testData()
//        
//        let symmetricKey = SymmetricKey(data: publicTransportKeyData)
//        let sealedBox = try CryptoKit.AES.GCM.SealedBox(combined: publicKeyEncryptedData)
//        
//        let decrypted = try CryptoKit.AES.GCM.open(sealedBox, using: symmetricKey)
//    }
//    
//    func test_serverPublicKeyEncryptedString_decryption_AES_GCM_2() throws {
//        
//        let (publicTransportKeyData, publicKeyEncryptedData) = try testData()
//        
//        let symmetricKey = SymmetricKey(data: publicTransportKeyData)
//        let sealedBox = try CryptoKit.AES.GCM.SealedBox(
//            nonce: .init(),
//            ciphertext: publicKeyEncryptedData,
//            tag: XCTUnwrap(Data(base64Encoded: "e1eIgoB4+lA/j3KDHhY4BQ=="))
//        )
//        
//        let decrypted = try CryptoKit.AES.GCM.open(sealedBox, using: symmetricKey)
//    }
//    
//    func test_serverPublicKeyEncryptedString_decryption_AES256() throws {
//        
//        let (publicTransportKeyData, publicKeyEncryptedData) = try testData()
//        
//        let iv = ForaBank.AES256.randomIv()
//        let aes = try ForaBank.AES256(key: publicTransportKeyData, iv: iv)
//        
//        let decrypted = try aes.decrypt(publicKeyEncryptedData)
//    }
//    
//    func test_serverPublicKeyEncryptedString_decryption_AESEncryptionAgent() throws {
//        
//        let (publicTransportKeyData, publicKeyEncryptedData) = try testData()
//        
//        let agent = AESEncryptionAgent(with: publicTransportKeyData)
//        let decrypted = try agent.decrypt(publicKeyEncryptedData)
//    }
//    
//    // MARK: Helpers
//    
//    private func testData() throws -> (Data, Data) {
//        
//        try (publicTransportKeyData(), publicKeyEncryptedData())
//    }
//    
//    private func publicTransportKeyData() throws -> Data {
//        
//        let publicTransportKey = try PublicTransportKeyDomain.fromCert()
//        let publicTransportKeyData = try XCTUnwrap(
//            SecKeyCopyExternalRepresentation(publicTransportKey, nil) as? Data
//        )
//        
//        return publicTransportKeyData
//    }
//    
//    private func publicKeyEncryptedData() throws -> Data {
//        
//        let publicKeyEncryptedData = try XCTUnwrap(Data(
//            base64Encoded: serverPublicKeyEncryptedString_im,
//            options: .ignoreUnknownCharacters
//        ))
//        
//        return publicKeyEncryptedData
//    }
//    
//    private let serverPublicKeyEncryptedString_rom0 = """
//MDAtptdwKafqhkhf3k21PlPblUNnUElfJvWQqeDQbi796VcZyPeoohlwQPSYOGokOMaAHI69xTkyogjYDs5w2DgsWmKXfGSvfxxvqTmASPJfqSxswZHlF/Db9ZGQIpvcY3d7eJwMzLpc4p0J7YCr5NLuuU9+1tFMcyXi+TtxN99fPzMh4g/W5qklrxPv5WVHUSgA8Kpsc8X9U9UIQe+SwJ4j9wSqaSdAGJlbeXqVxROXhZLwqAwPw6g2hrQe5U/s3gLh+2/RXjNOlcnx7DhMCQM8ZZYrZn4Rp98xB6h6SOJ92ae8NsB4K+rjsVuamvrPxCzJHJD22tKQMwoADykxV90PBF7RwErxiV495WxLTSQpkyggi6Am3IFPl3no8teKkjFUHVDb8c2tJrf5xJRmiuu1uJ0jYTEjIDpkmtf2GA4Bj3/6izkthAdorKfnuiSdUhC2ZOIltjZpyQnesjkQfGxZ+4pRtUToltb1cZ0UnstttSNZmyWPXgQLr7NACLQ9uaF6eetWQXQJ2r+YGXn4mvcdFt0d8mg7XA7sZdRCnxS68TKlWKJ12TWsk/ypqmlTPyMTw9clL64bFUN0YbyqbF6TkObe8eBaJrilpKhd53HD0YXYdEAqPUVqkMggVTj5d4rcg1jwAUVRCXemJE/LbQC965YBvaZNXeDizXHDFEs=
//"""
//    
//    private let serverPublicKeyEncryptedString_im = """
//hXo7T5pm1yFVqFYui9cSbdvFMAW7W2AqH09uWiAtxo4uPGk+GG1xSoXkvaD49iSPKcIuyaDJzdEsDxdG4fgntAHAgp3PhAMyIPl+nXosAqsjRj/9MwNvvlt+10dsAqg/mUYccCz1mvkdfXuM3UlQbKL7WFUtVqXwK8DWAljjFX1P6+HeSSB+Egy94BiVjVtiFVwcOLJSZNMLyVf4x4p2GmDYgjLk4T/rlBZRoRlSuBiTjhEngiy+zdGHn9P8JnO+JqpEzEagEqt2HkpK7bhPecbbhjForr2+lhnW4P1rI97tyv5A5wIkgW6TTRWxdlCjggFO1aubDFFfNoQFcxOX12lbMHfk9YbAi6Z/tYiyYIdziLoSeeYozI7LmuP28mHBt2zwqG8xFoxm32dydR9CyVpnLLQ/AfkyWXcdh08NC0EzJUydIseLejJUhHt2fbAIuEHDNeo3efNNS+mksDa8SPtySy4ZOy869ZqmZc2oAMHFvFMbovt2IR87Zp1o37Pvuf+O+GbpNUneoUKhG/5tEDiAFaygEX3OIPHsk5Tq2uqSj11TWJ0iKrReguxzGOAR4tYiMRagnkShAgQgD1UBRrDUPEIjhnUZxcdPIhm/kXtpFXycI7qGBrPfNrjg1lyLVyQzUc2cK87LVQMj7luYb92HslmqqzKgErrTYgcJWOw=
//"""
//    
//}
