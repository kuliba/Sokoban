//
//  certificateFromFile.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

import ForaCrypto
import XCTest

final class CertificateFromFileTests: XCTestCase {
    
    func test() throws {
        
        let certificate = try certificateFromFile(at: publicDerCrtURL)
        let publicKey = try publicKey(from: certificate)
        
        
        let data = Data("test".utf8)
        
        let encrypted = try XCTUnwrap(
            Crypto.encryptWithRSAKey(
                data,
                publicKey: publicKey,
                padding: .PKCS1
            )
        )
        
        let keyData = try publicKey.rawRepresentation()
        let base64 = keyData.base64EncodedString()
        
        XCTAssertNoDiff(base64, rom_transportPublicKey)
        XCTAssertEqual(base64.count, 704)
        XCTAssertEqual(rom_transportPublicKey.count, 736)

        
        XCTAssertEqual(encrypted.count, 512)
        
        let base64Encrypted = encrypted.base64EncodedString()
        
        XCTAssertEqual(base64Encrypted, rom_test_encryptedWithTransportPublicKey)
        XCTAssertEqual(base64Encrypted.count, 684)
        XCTAssertEqual(rom_test_encryptedWithTransportPublicKey.count, 684)
    }
    
    // MARK: - Helpers
    
#warning("REPEATED, move to shared scope")
    private let rom_test_encryptedWithTransportPublicKey = """
hn4zOFL2MgMODvfMVy7jnGkGjnQ8lk2R7UHo8aE3IOjWXN6dptMdcUQmH25nlvCGl7o4MBVnftDsMPAl44ya9TbGk5Oy8P68JDZL9ov0Yd5siwdSYUfLHRNpSu/lBPjnKhUe0BxtkDQ6ZZlX0OhDmz4n5PPAwh16Z8SvzuS8GIrdFKLR1PDPaO+MKfIYrOo+lvDQM7UhcN3A6bLCqm8uZoUcDRwEOPGkmwB+/IYgoYlisT5d3uO1+INr26jwZjMCXCJbZmsdgMtPcEemQkGB1PAlu1qXZzWXDSWIjZ5xMJ8MfGWKa+ClmsqGnr454wpqqRnyODsNp7taLZg3R0ad9kyOSuoMai9wnsmuK7JOUvPetN4ultQ2piEgxJp+qOfFOmhqbmEHWXqCYti41VUSCYyA5HPaCB4LsUFJTlSG2vYJ6xIz7X8xXJC/HoDzZRUXE+BIrO1mfyhK6YzgJJiBVvGolbIf0El9ddeQ0XSKXLCQ/EgI6M6PrR1E66TBe6IAQExPyq8hDkcgE5zDlVe7z019UGAUWJebPoaA9PqAwqFEXHz18LLbKyl8sVnaxfcnEFLS+wVD8/BdqBVTXypATgdDv3VaduHHVvF5HlH/aSJ0ALiT6V12OP6xFPiJr73gSmNGOxRP1QeKqT6mpLPh0RxnBZhpYsFaH69MfnMGWX4=
"""
    
    private let rom_transportPublicKey = """
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqFiLSMrlywB8Oh9LK8eqXUTczsgleaHF0Au0zdAIxaHyE1nvLs6Kemx6nGCdLLL6+acqQnRGTY1lqFlh3bKmtWWijAonL+55dViT3BqEuq1pJA+Ut915Jh3UhRTsn7Oc50wP6rcjH7njqP7hdMTVfjJkgLoWW7tIYRdfXL4IhzCUGMBry5+wh0URDKSvtbsD0292mJEGN2gxbEkjd7++BxjPt5TvD6VK3xCHDguFUDwti5ItgWyiCTEKxeX6xuzUFpz3PFHi4w34f8G5ceTwkjBlmBE6ybdY2l5ixVDoHOjnJL01S9lQpu8dkwykNybaLcjA8zIF++JDQxYEv3q7JXL1ebtIoug4ijzpqIUoqmcXLuDZkyJ3E16Gd35oIVtJ8gDwN7Rq8RHI9ishxKrFhVycXzhs5kwkPCK2/6jJp9R7vA7N81mFq1NQYOokXV/doQHJpYilthI1DJO+tp8lZ1x8MonPTkHYGI3oqYAV4GwvHRQywuIHddlLvf1avvILdyRBvX+a54rD50GBtZHP+aFzWYt6z6HqmuFw3awDzElZknhyWCRcS7a7LeqCXF58hPaY/cHSNP0wmsrqxPC/lzbNaysK9mqwPjdi++c5Yq9nmMfXC7JWq9cbXUYNGJnXjLqwnVwrUCmdxo7e1z8L7Q0hFJfzTPENNDS2Xwx9yW0CAwEAAQ==
"""
}

import Foundation
import Security

enum CertificateError: Error {
    case unableToReadFile
    case unableToCreateCertificate
    case unableToExtractPublicKey
}

func certificateFromFile(at url: URL) throws -> SecCertificate {
    // 1. Read the .crt file data
    guard let certificateData = try? Data(contentsOf: url) else {
        throw CertificateError.unableToReadFile
    }
    
    // 2. Create a certificate from the data
    guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
        throw CertificateError.unableToCreateCertificate
    }
    
    return certificate
}

func publicKey(from certificate: SecCertificate) throws -> SecKey {
    // Create a policy for the certificate
    let policy = SecPolicyCreateBasicX509()
    
    // Extract the trust object
    var trust: SecTrust?
    let status = SecTrustCreateWithCertificates(
        certificate,
        policy,
        &trust
    )
    
    guard status == errSecSuccess,
          let validTrust = trust
    else {
        throw CertificateError.unableToExtractPublicKey
    }
    
    // Get the public key from the trust object
    guard let publicKey = SecTrustCopyPublicKey(validTrust)
    else {
        throw CertificateError.unableToExtractPublicKey
    }
    
    return publicKey
}
