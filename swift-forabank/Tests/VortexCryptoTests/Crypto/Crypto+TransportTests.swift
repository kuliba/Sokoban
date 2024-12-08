//
//  Crypto+TransportTests.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

import VortexCrypto
import XCTest

final class Crypto_TransportTests: XCTestCase {
    // 
    func test_transportEncrypt_shouldMakeDataWithSizeOf512() throws {
        
        let data = Data("very very important message".utf8)
        
        let encrypted = try Crypto.transportEncrypt(data)
        
        XCTAssertNoDiff(encrypted.count, 512)
    }
    
    func test_transportEncrypt_test() throws {
        
        let data = Data("test".utf8)
        
        let encrypted = try Crypto.transportEncrypt(data)
        
        XCTAssertNoDiff(encrypted.count, 512)
        
        let base64 = encrypted.base64EncodedString()
        
        XCTAssertNoDiff(base64, rom_test_encryptedWithTransportPublicKey)
        XCTAssertNoDiff(base64.count, 684)
        XCTAssertNoDiff(rom_test_encryptedWithTransportPublicKey.count, 684)
    }
    
    func test_encryptWithRSAKey_transportKey_test() throws {
        
        let data = Data("test".utf8)
        
        let encrypted = try XCTUnwrap(
            Crypto.encryptWithRSAKey(
                data,
                publicKey: Crypto.transportKey(),
                padding: .OAEP
            )
        )
        XCTAssertNoDiff(encrypted.count, 512)
        
        let base64 = encrypted.base64EncodedString()
        
        XCTExpectFailure("experiments in search of solution")
        XCTAssertNoDiff(base64, rom_test_encryptedWithTransportPublicKey)
        XCTAssertNoDiff(base64.count, 684)
        XCTAssertNoDiff(rom_test_encryptedWithTransportPublicKey.count, 684)
    }
    
    func test_publicTransportKey() throws {
        
        let key = try Crypto.transportKey()
        
        let keyData = try key.rawRepresentation()
        let base64 = keyData.base64EncodedString()
        
        XCTExpectFailure("experiments in search of solution")
        XCTAssertNoDiff(base64, rom_transportPublicKey)
        XCTAssertNoDiff(base64.count, 704)
        XCTAssertNoDiff(rom_transportPublicKey.count, 736)
    }
    
    func test_transportPublicKey_length() throws {
        
        try XCTAssertNoDiff(
            transportPublicKey().rawRepresentation().count,
            526
        )
    }
    
    // MARK: - Helpers
    
    private func transportPublicKey() throws -> SecKey {
        
        try Crypto.transportKey()
    }
    
    private let rom_test_encryptedWithTransportPublicKey = """
hn4zOFL2MgMODvfMVy7jnGkGjnQ8lk2R7UHo8aE3IOjWXN6dptMdcUQmH25nlvCGl7o4MBVnftDsMPAl44ya9TbGk5Oy8P68JDZL9ov0Yd5siwdSYUfLHRNpSu/lBPjnKhUe0BxtkDQ6ZZlX0OhDmz4n5PPAwh16Z8SvzuS8GIrdFKLR1PDPaO+MKfIYrOo+lvDQM7UhcN3A6bLCqm8uZoUcDRwEOPGkmwB+/IYgoYlisT5d3uO1+INr26jwZjMCXCJbZmsdgMtPcEemQkGB1PAlu1qXZzWXDSWIjZ5xMJ8MfGWKa+ClmsqGnr454wpqqRnyODsNp7taLZg3R0ad9kyOSuoMai9wnsmuK7JOUvPetN4ultQ2piEgxJp+qOfFOmhqbmEHWXqCYti41VUSCYyA5HPaCB4LsUFJTlSG2vYJ6xIz7X8xXJC/HoDzZRUXE+BIrO1mfyhK6YzgJJiBVvGolbIf0El9ddeQ0XSKXLCQ/EgI6M6PrR1E66TBe6IAQExPyq8hDkcgE5zDlVe7z019UGAUWJebPoaA9PqAwqFEXHz18LLbKyl8sVnaxfcnEFLS+wVD8/BdqBVTXypATgdDv3VaduHHVvF5HlH/aSJ0ALiT6V12OP6xFPiJr73gSmNGOxRP1QeKqT6mpLPh0RxnBZhpYsFaH69MfnMGWX4=
"""
    
    private let rom_transportPublicKey = """
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqFiLSMrlywB8Oh9LK8eqXUTczsgleaHF0Au0zdAIxaHyE1nvLs6Kemx6nGCdLLL6+acqQnRGTY1lqFlh3bKmtWWijAonL+55dViT3BqEuq1pJA+Ut915Jh3UhRTsn7Oc50wP6rcjH7njqP7hdMTVfjJkgLoWW7tIYRdfXL4IhzCUGMBry5+wh0URDKSvtbsD0292mJEGN2gxbEkjd7++BxjPt5TvD6VK3xCHDguFUDwti5ItgWyiCTEKxeX6xuzUFpz3PFHi4w34f8G5ceTwkjBlmBE6ybdY2l5ixVDoHOjnJL01S9lQpu8dkwykNybaLcjA8zIF++JDQxYEv3q7JXL1ebtIoug4ijzpqIUoqmcXLuDZkyJ3E16Gd35oIVtJ8gDwN7Rq8RHI9ishxKrFhVycXzhs5kwkPCK2/6jJp9R7vA7N81mFq1NQYOokXV/doQHJpYilthI1DJO+tp8lZ1x8MonPTkHYGI3oqYAV4GwvHRQywuIHddlLvf1avvILdyRBvX+a54rD50GBtZHP+aFzWYt6z6HqmuFw3awDzElZknhyWCRcS7a7LeqCXF58hPaY/cHSNP0wmsrqxPC/lzbNaysK9mqwPjdi++c5Yq9nmMfXC7JWq9cbXUYNGJnXjLqwnVwrUCmdxo7e1z8L7Q0hFJfzTPENNDS2Xwx9yW0CAwEAAQ==
"""
}
