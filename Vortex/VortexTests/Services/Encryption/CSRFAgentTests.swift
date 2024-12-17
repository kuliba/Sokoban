//
//  CSRFAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 23.01.2022.
//

import XCTest
@testable import ForaBank

class CSRFAgentTests: XCTestCase {

    func testPemCertsFromStringData() throws {
        
        // given
        let certDataSample = Self.serverCertificatesBase64String
        let expectedFirstCert =
                """
                -----BEGIN CERTIFICATE-----\nMIIGNTCCBR2gAwIBAgISBKnOfqdiCLloeNKeDzAOov4lMA0GCSqGSIb3DQEBCwUA\nMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD\nEwJSMzAeFw0yMTAzMTUwNjQyMTJaFw0yMTA2MTMwNjQyMTJaMCExHzAdBgNVBAMT\nFnNydi1tYWlsLmJyaWdpbnZlc3QucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw\nggEKAoIBAQDk8MnLutFgkE6sObZZIyxBrq2T7F3aTykbysL59PkZRIpC3yJ+otq7\nzbAOAZ6081TpjFRc3zQu9AAEWssxDdgZKZxIYWxNe2Eg2uJtzctUmpH3eVyTLaYZ\nrEiFwVdTQeCcg+JPLAZ9nsdjAKsIccB44+s4GMAXxBJtQlsozUd/MaAvUfjrTsmR\nEK1bu2REraBvlMbSyNSeO8JlI0d1pHnmOkM70Pcvj5FUEIx17kJ3xfykHtVtZa/a\nZUXgSVLynTnuPVGpNjNVkfw+z89sbKAJd85e7U/kV86vwoOKaXnFrcYhM8r25tSg\nahmEI+v8A+7vNjjqgDNIKU8zbbMxzCrbAgMBAAGjggNUMIIDUDAOBgNVHQ8BAf8E\nBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQC\nMAAwHQYDVR0OBBYEFEFvpLzLkVQzxy4wemarIGSKhJCjMB8GA1UdIwQYMBaAFBQu\nsxe3WFbLrlAJQOYfr52LFMLGMFUGCCsGAQUFBwEBBEkwRzAhBggrBgEFBQcwAYYV\naHR0cDovL3IzLm8ubGVuY3Iub3JnMCIGCCsGAQUFBzAChhZodHRwOi8vcjMuaS5s\nZW5jci5vcmcvMIIBIQYDVR0RBIIBGDCCARSCEmNoYXQuYnJpZ2ludmVzdC5ydYIN\nY2hhdC5pbm40Yi5ydYIRZ2l0LmJyaWdpbnZlc3QucnWCDGdpdC5pbm40Yi5ydYIM\naW5uNGIub25saW5lgghpbm40Yi5ydYISamlyYS5icmlnaW52ZXN0LnJ1ghFqaXJh\nLmlubjRiLm9ubGluZYINamlyYS5pbm40Yi5ydYIScm92MjEuaW5uNGIub25saW5l\ngg5yb3YyMS5pbm40Yi5ydYIWc3J2LW1haWwuYnJpZ2ludmVzdC5ydYIRc3J2LW1h\naWwuaW5uNGIucnWCEXRmcy5icmlnaW52ZXN0LnJ1ghB3d3cuaW5uNGIub25saW5l\nggx3d3cuaW5uNGIucnUwTAYDVR0gBEUwQzAIBgZngQwBAgEwNwYLKwYBBAGC3xMB\nAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5jcnlwdC5vcmcwggEF\nBgorBgEEAdZ5AgQCBIH2BIHzAPEAdwD2XJQv0XcwIhRUGAgwlFaO400TGTO/3wwv\nIAvMTvFk4wAAAXg01dU/AAAEAwBIMEYCIQCXcU/71xjQtpKr5Xa/Nyndp/preAx7\nAyhoM4ZIdU2TygIhAKABQImwOLlJP3eyhEQxKSruDR/TuJEMGOkiDeZ4BP2FAHYA\nb1N2rDHwMRnYmQCkURX/dxUcEdkCwQApBo2yCJo32RMAAAF4NNXWBgAABAMARzBF\nAiEA6ZKg69wYtyS3dU9tTzANVJJLBo/ZVh1KJH43H/YgCSMCIBxIO22VilC8is38\nbGkx3YoBPUq8HZ9BnnOhsIrXGaW4MA0GCSqGSIb3DQEBCwUAA4IBAQBZYqAsANNa\nz4WVabxPG/KGG0T1CfOL4kdkM9Qgx9g3hw4J0qJPoQ60QVliKyUwHpcKmMF+AT20\nEsYl9Cu5DjA+PpjK0dMSYohuIs+nWVO7Flz876LDNDL2K15dHWYN0US9Bc+tsSZs\nD41e1deg8UYJQFnYtx7DQO1FDGaSu7iXGhuoTsLwBQrXs68aG7kJgfjJmfIiYzC5\nAll1leJQvG4IfqZPvEY3SZmhRuAaz17di0jLoEQnIC95HiEs05PZSsa9MTVBPVni\ntWQ7rrKUXKg0NcV9ZXp9t+Wn9XnBx+0I6tDOjtwuV/8Y9gR0q3s6lAa9oiLU5FZq\nncWUIW9udlDl\n-----END CERTIFICATE-----\n
                """
        
        let expectedSecondSert =
                """
                -----BEGIN CERTIFICATE-----\nMIIEZTCCA02gAwIBAgIQQAF1BIMUpMghjISpDBbN3zANBgkqhkiG9w0BAQsFADA/\nMSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT\nDkRTVCBSb290IENBIFgzMB4XDTIwMTAwNzE5MjE0MFoXDTIxMDkyOTE5MjE0MFow\nMjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxCzAJBgNVBAMT\nAlIzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuwIVKMz2oJTTDxLs\njVWSw/iC8ZmmekKIp10mqrUrucVMsa+Oa/l1yKPXD0eUFFU1V4yeqKI5GfWCPEKp\nTm71O8Mu243AsFzzWTjn7c9p8FoLG77AlCQlh/o3cbMT5xys4Zvv2+Q7RVJFlqnB\nU840yFLuta7tj95gcOKlVKu2bQ6XpUA0ayvTvGbrZjR8+muLj1cpmfgwF126cm/7\ngcWt0oZYPRfH5wm78Sv3htzB2nFd1EbjzK0lwYi8YGd1ZrPxGPeiXOZT/zqItkel\n/xMY6pgJdz+dU/nPAeX1pnAXFK9jpP+Zs5Od3FOnBv5IhR2haa4ldbsTzFID9e1R\noYvbFQIDAQABo4IBaDCCAWQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8E\nBAMCAYYwSwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5p\nZGVudHJ1c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTE\np7Gkeyxx+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEE\nAYLfEwEBATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2Vu\nY3J5cHQub3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0\nLmNvbS9EU1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYf\nr52LFMLGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjANBgkqhkiG9w0B\nAQsFAAOCAQEA2UzgyfWEiDcx27sT4rP8i2tiEmxYt0l+PAK3qB8oYevO4C5z70kH\nejWEHx2taPDY/laBL21/WKZuNTYQHHPD5b1tXgHXbnL7KqC401dk5VvCadTQsvd8\nS8MXjohyc9z9/G2948kLjmE6Flh9dDYrVYA9x2O+hEPGOaEOa1eePynBgPayvUfL\nqjBstzLhWVQLGAkXXmNs+5ZnPBxzDJOLxhF2JIbeQAcH5H0tZrUlo5ZYyOqA7s9p\nO5b85o3AM/OJ+CktFBQtfvBhcJVd9wvlwPsk+uyOy2HI7mNxKKgsBTt375teA2Tw\nUdHkhVNcsAKX1H7GNNLOEADksd86wuoXvg==\n-----END CERTIFICATE-----\n
                """
        
        // when
        let result = CSRFAgent<AESEncryptionAgent>.pemCertificates(from: certDataSample)
        
        // then
        XCTAssertEqual(result[0], expectedFirstCert)
        XCTAssertEqual(result[1], expectedSecondSert)
    }
    
    func testCertificateDataFromPemString() throws {
        
        // given
        let pemSample =
                """
                -----BEGIN CERTIFICATE-----\nMIIGNTCCBR2gAwIBAgISBKnOfqdiCLloeNKeDzAOov4lMA0GCSqGSIb3DQEBCwUA\nMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD\nEwJSMzAeFw0yMTAzMTUwNjQyMTJaFw0yMTA2MTMwNjQyMTJaMCExHzAdBgNVBAMT\nFnNydi1tYWlsLmJyaWdpbnZlc3QucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw\nggEKAoIBAQDk8MnLutFgkE6sObZZIyxBrq2T7F3aTykbysL59PkZRIpC3yJ+otq7\nzbAOAZ6081TpjFRc3zQu9AAEWssxDdgZKZxIYWxNe2Eg2uJtzctUmpH3eVyTLaYZ\nrEiFwVdTQeCcg+JPLAZ9nsdjAKsIccB44+s4GMAXxBJtQlsozUd/MaAvUfjrTsmR\nEK1bu2REraBvlMbSyNSeO8JlI0d1pHnmOkM70Pcvj5FUEIx17kJ3xfykHtVtZa/a\nZUXgSVLynTnuPVGpNjNVkfw+z89sbKAJd85e7U/kV86vwoOKaXnFrcYhM8r25tSg\nahmEI+v8A+7vNjjqgDNIKU8zbbMxzCrbAgMBAAGjggNUMIIDUDAOBgNVHQ8BAf8E\nBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQC\nMAAwHQYDVR0OBBYEFEFvpLzLkVQzxy4wemarIGSKhJCjMB8GA1UdIwQYMBaAFBQu\nsxe3WFbLrlAJQOYfr52LFMLGMFUGCCsGAQUFBwEBBEkwRzAhBggrBgEFBQcwAYYV\naHR0cDovL3IzLm8ubGVuY3Iub3JnMCIGCCsGAQUFBzAChhZodHRwOi8vcjMuaS5s\nZW5jci5vcmcvMIIBIQYDVR0RBIIBGDCCARSCEmNoYXQuYnJpZ2ludmVzdC5ydYIN\nY2hhdC5pbm40Yi5ydYIRZ2l0LmJyaWdpbnZlc3QucnWCDGdpdC5pbm40Yi5ydYIM\naW5uNGIub25saW5lgghpbm40Yi5ydYISamlyYS5icmlnaW52ZXN0LnJ1ghFqaXJh\nLmlubjRiLm9ubGluZYINamlyYS5pbm40Yi5ydYIScm92MjEuaW5uNGIub25saW5l\ngg5yb3YyMS5pbm40Yi5ydYIWc3J2LW1haWwuYnJpZ2ludmVzdC5ydYIRc3J2LW1h\naWwuaW5uNGIucnWCEXRmcy5icmlnaW52ZXN0LnJ1ghB3d3cuaW5uNGIub25saW5l\nggx3d3cuaW5uNGIucnUwTAYDVR0gBEUwQzAIBgZngQwBAgEwNwYLKwYBBAGC3xMB\nAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5jcnlwdC5vcmcwggEF\nBgorBgEEAdZ5AgQCBIH2BIHzAPEAdwD2XJQv0XcwIhRUGAgwlFaO400TGTO/3wwv\nIAvMTvFk4wAAAXg01dU/AAAEAwBIMEYCIQCXcU/71xjQtpKr5Xa/Nyndp/preAx7\nAyhoM4ZIdU2TygIhAKABQImwOLlJP3eyhEQxKSruDR/TuJEMGOkiDeZ4BP2FAHYA\nb1N2rDHwMRnYmQCkURX/dxUcEdkCwQApBo2yCJo32RMAAAF4NNXWBgAABAMARzBF\nAiEA6ZKg69wYtyS3dU9tTzANVJJLBo/ZVh1KJH43H/YgCSMCIBxIO22VilC8is38\nbGkx3YoBPUq8HZ9BnnOhsIrXGaW4MA0GCSqGSIb3DQEBCwUAA4IBAQBZYqAsANNa\nz4WVabxPG/KGG0T1CfOL4kdkM9Qgx9g3hw4J0qJPoQ60QVliKyUwHpcKmMF+AT20\nEsYl9Cu5DjA+PpjK0dMSYohuIs+nWVO7Flz876LDNDL2K15dHWYN0US9Bc+tsSZs\nD41e1deg8UYJQFnYtx7DQO1FDGaSu7iXGhuoTsLwBQrXs68aG7kJgfjJmfIiYzC5\nAll1leJQvG4IfqZPvEY3SZmhRuAaz17di0jLoEQnIC95HiEs05PZSsa9MTVBPVni\ntWQ7rrKUXKg0NcV9ZXp9t+Wn9XnBx+0I6tDOjtwuV/8Y9gR0q3s6lAa9oiLU5FZq\nncWUIW9udlDl\n-----END CERTIFICATE-----\n
                """
        
        // when
        let result = try CSRFAgent<AESEncryptionAgent>.certificate(from: pemSample)
        let info = SecCertificateCopySubjectSummary(result) as String?
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(info, "srv-mail.briginvest.ru")
    }
    
    func testServerCertPublicKey() throws {
        
        // given
        let serverCertsDataSample = Self.serverCertificatesBase64String
        
        // when
        let resultKey = try CSRFAgent<AESEncryptionAgent>.serverCertPublicKey(serverCertsDataSample)
        let resultKeyData = try externalKeyData(from: resultKey)
        let resultKeyDataBase64String = resultKeyData.base64EncodedString()
        
        // then
        XCTAssertEqual(resultKeyDataBase64String, Self.serverCertPublicKeyBase64String)
    }
    
    func testServerPublicKey() throws {
        
        // given
        let serverCertKey = try CSRFAgent<AESEncryptionAgent>.serverCertPublicKey(Self.serverCertificatesBase64String)
        
        // when
        let resultKey = try CSRFAgent<AESEncryptionAgent>.serverPublicKey(serverCertKey, Self.serverEncryptedPublicKeyBase64String)
        let resultKeyData = try externalKeyData(from: resultKey)
        let resultKeyDataBase64String = resultKeyData.base64EncodedString()
        
        // then
        XCTAssertEqual(resultKeyDataBase64String, Self.serverDecryptedPublicKeyBase64String)
    }
    
    func testSharedSecret() throws {
        
        // given
        let privateKey = try createSecKey(from: Self.privateKeyBase64String, type: .private)
        let serverCertKey = try CSRFAgent<AESEncryptionAgent>.serverCertPublicKey(Self.serverCertificatesBase64String)
        let serverPublicKey = try CSRFAgent<AESEncryptionAgent>.serverPublicKey(serverCertKey, Self.serverEncryptedPublicKeyBase64String)
        
        // when
        let resultKeyData = try CSRFAgent<AESEncryptionAgent>.sharedSecretData(privateKey, serverPublicKey)
        let resultKeyDataBase64String = resultKeyData.base64EncodedString()
        
        // then
        XCTAssertEqual(resultKeyDataBase64String, Self.sharedSecretKeyBase64String)
    }
    
    func testConfigure_With_Mock() throws {
        
        // given
        let publicKey = try createSecKey(from: Self.publicKeyBase64String, type: .public)
        let privateKey = try createSecKey(from: Self.privateKeyBase64String, type: .private)
        let keysProvider = KeysProviderMock(publcKey: publicKey, privateKey: privateKey)
        let expected = "test123456789"
        
        // when
        let csrfAgent = try CSRFAgent<AESEncryptionAgent>(keysProvider, Self.serverCertificatesBase64String, Self.serverEncryptedPublicKeyBase64String)
        let encrypted = try csrfAgent.encrypt(expected)
        let decrypted = try csrfAgent.decrypt(encrypted)
        
        // then
        XCTAssertEqual(decrypted, expected)
    }
    
    func testConfigure() throws {
        
        // given
        let expected = "test123456789"
        
        // when
        let csrfAgent = try CSRFAgent<AESEncryptionAgent>(ECKeysProvider(), Self.serverCertificatesBase64String, Self.serverEncryptedPublicKeyBase64String)
        let encrypted = try csrfAgent.encrypt(expected)
        let decrypted = try csrfAgent.decrypt(encrypted)
        
        // then
        XCTAssertEqual(decrypted, expected)
    }
}

//MARK: - Sample Data

extension CSRFAgentTests {
    
    static let serverCertificatesBase64String = """
    -----BEGIN CERTIFICATE-----\nMIIGNTCCBR2gAwIBAgISBKnOfqdiCLloeNKeDzAOov4lMA0GCSqGSIb3DQEBCwUA\nMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD\nEwJSMzAeFw0yMTAzMTUwNjQyMTJaFw0yMTA2MTMwNjQyMTJaMCExHzAdBgNVBAMT\nFnNydi1tYWlsLmJyaWdpbnZlc3QucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw\nggEKAoIBAQDk8MnLutFgkE6sObZZIyxBrq2T7F3aTykbysL59PkZRIpC3yJ+otq7\nzbAOAZ6081TpjFRc3zQu9AAEWssxDdgZKZxIYWxNe2Eg2uJtzctUmpH3eVyTLaYZ\nrEiFwVdTQeCcg+JPLAZ9nsdjAKsIccB44+s4GMAXxBJtQlsozUd/MaAvUfjrTsmR\nEK1bu2REraBvlMbSyNSeO8JlI0d1pHnmOkM70Pcvj5FUEIx17kJ3xfykHtVtZa/a\nZUXgSVLynTnuPVGpNjNVkfw+z89sbKAJd85e7U/kV86vwoOKaXnFrcYhM8r25tSg\nahmEI+v8A+7vNjjqgDNIKU8zbbMxzCrbAgMBAAGjggNUMIIDUDAOBgNVHQ8BAf8E\nBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQC\nMAAwHQYDVR0OBBYEFEFvpLzLkVQzxy4wemarIGSKhJCjMB8GA1UdIwQYMBaAFBQu\nsxe3WFbLrlAJQOYfr52LFMLGMFUGCCsGAQUFBwEBBEkwRzAhBggrBgEFBQcwAYYV\naHR0cDovL3IzLm8ubGVuY3Iub3JnMCIGCCsGAQUFBzAChhZodHRwOi8vcjMuaS5s\nZW5jci5vcmcvMIIBIQYDVR0RBIIBGDCCARSCEmNoYXQuYnJpZ2ludmVzdC5ydYIN\nY2hhdC5pbm40Yi5ydYIRZ2l0LmJyaWdpbnZlc3QucnWCDGdpdC5pbm40Yi5ydYIM\naW5uNGIub25saW5lgghpbm40Yi5ydYISamlyYS5icmlnaW52ZXN0LnJ1ghFqaXJh\nLmlubjRiLm9ubGluZYINamlyYS5pbm40Yi5ydYIScm92MjEuaW5uNGIub25saW5l\ngg5yb3YyMS5pbm40Yi5ydYIWc3J2LW1haWwuYnJpZ2ludmVzdC5ydYIRc3J2LW1h\naWwuaW5uNGIucnWCEXRmcy5icmlnaW52ZXN0LnJ1ghB3d3cuaW5uNGIub25saW5l\nggx3d3cuaW5uNGIucnUwTAYDVR0gBEUwQzAIBgZngQwBAgEwNwYLKwYBBAGC3xMB\nAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5jcnlwdC5vcmcwggEF\nBgorBgEEAdZ5AgQCBIH2BIHzAPEAdwD2XJQv0XcwIhRUGAgwlFaO400TGTO/3wwv\nIAvMTvFk4wAAAXg01dU/AAAEAwBIMEYCIQCXcU/71xjQtpKr5Xa/Nyndp/preAx7\nAyhoM4ZIdU2TygIhAKABQImwOLlJP3eyhEQxKSruDR/TuJEMGOkiDeZ4BP2FAHYA\nb1N2rDHwMRnYmQCkURX/dxUcEdkCwQApBo2yCJo32RMAAAF4NNXWBgAABAMARzBF\nAiEA6ZKg69wYtyS3dU9tTzANVJJLBo/ZVh1KJH43H/YgCSMCIBxIO22VilC8is38\nbGkx3YoBPUq8HZ9BnnOhsIrXGaW4MA0GCSqGSIb3DQEBCwUAA4IBAQBZYqAsANNa\nz4WVabxPG/KGG0T1CfOL4kdkM9Qgx9g3hw4J0qJPoQ60QVliKyUwHpcKmMF+AT20\nEsYl9Cu5DjA+PpjK0dMSYohuIs+nWVO7Flz876LDNDL2K15dHWYN0US9Bc+tsSZs\nD41e1deg8UYJQFnYtx7DQO1FDGaSu7iXGhuoTsLwBQrXs68aG7kJgfjJmfIiYzC5\nAll1leJQvG4IfqZPvEY3SZmhRuAaz17di0jLoEQnIC95HiEs05PZSsa9MTVBPVni\ntWQ7rrKUXKg0NcV9ZXp9t+Wn9XnBx+0I6tDOjtwuV/8Y9gR0q3s6lAa9oiLU5FZq\nncWUIW9udlDl\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIEZTCCA02gAwIBAgIQQAF1BIMUpMghjISpDBbN3zANBgkqhkiG9w0BAQsFADA/\nMSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT\nDkRTVCBSb290IENBIFgzMB4XDTIwMTAwNzE5MjE0MFoXDTIxMDkyOTE5MjE0MFow\nMjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxCzAJBgNVBAMT\nAlIzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuwIVKMz2oJTTDxLs\njVWSw/iC8ZmmekKIp10mqrUrucVMsa+Oa/l1yKPXD0eUFFU1V4yeqKI5GfWCPEKp\nTm71O8Mu243AsFzzWTjn7c9p8FoLG77AlCQlh/o3cbMT5xys4Zvv2+Q7RVJFlqnB\nU840yFLuta7tj95gcOKlVKu2bQ6XpUA0ayvTvGbrZjR8+muLj1cpmfgwF126cm/7\ngcWt0oZYPRfH5wm78Sv3htzB2nFd1EbjzK0lwYi8YGd1ZrPxGPeiXOZT/zqItkel\n/xMY6pgJdz+dU/nPAeX1pnAXFK9jpP+Zs5Od3FOnBv5IhR2haa4ldbsTzFID9e1R\noYvbFQIDAQABo4IBaDCCAWQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8E\nBAMCAYYwSwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5p\nZGVudHJ1c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTE\np7Gkeyxx+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEE\nAYLfEwEBATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2Vu\nY3J5cHQub3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0\nLmNvbS9EU1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYf\nr52LFMLGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjANBgkqhkiG9w0B\nAQsFAAOCAQEA2UzgyfWEiDcx27sT4rP8i2tiEmxYt0l+PAK3qB8oYevO4C5z70kH\nejWEHx2taPDY/laBL21/WKZuNTYQHHPD5b1tXgHXbnL7KqC401dk5VvCadTQsvd8\nS8MXjohyc9z9/G2948kLjmE6Flh9dDYrVYA9x2O+hEPGOaEOa1eePynBgPayvUfL\nqjBstzLhWVQLGAkXXmNs+5ZnPBxzDJOLxhF2JIbeQAcH5H0tZrUlo5ZYyOqA7s9p\nO5b85o3AM/OJ+CktFBQtfvBhcJVd9wvlwPsk+uyOy2HI7mNxKKgsBTt375teA2Tw\nUdHkhVNcsAKX1H7GNNLOEADksd86wuoXvg==\n-----END CERTIFICATE-----\n
    """
    
    static let serverEncryptedPublicKeyBase64String = """
    DCi4KaXAu7/vhtlqIM3J515P0/VuOzheew2qYwgH06hKIew94cCRtWqn24NvNUe8AFLjH3sdOXMU+MFORCX2x/KuCQCNj0Oh6id0POAoXo4yaGEAMpLQFFNbc3X/veeOEbG9fBdWD1S5FXQWYafNuLpyjBh+SRlgoz642EDvLlSoOAS+ZuMaXumICnKkHKHr7Up0uxhQt9X9K3e5iBdTevFMK1pdig6KTb32+BJX8Y+rVMx4sd6l2JNtgTeiLDm5f8PNl9at5R9tOclmGNjrFsTRelgYswvgXZuTNIMnIXwOBuswd75ROMtdZlEzcYSph+K5PR56P6lutm+PpIC+Ig==
    """
    
    static let publicKeyBase64String = """
    BKvjgSfVKP2LfEhimFPCgw5C0z6P9JfQWAUENcqond8ym87MPxWU3A68cgWVzNs1oUIZwkwb6CyYSeB5eaSYPemnM/7Z3mD+sLdUJj5HOgs+c2mGINhf4CPVa5tMt8+zZg==
    """
    
    static let privateKeyBase64String = """
    BKvjgSfVKP2LfEhimFPCgw5C0z6P9JfQWAUENcqond8ym87MPxWU3A68cgWVzNs1oUIZwkwb6CyYSeB5eaSYPemnM/7Z3mD+sLdUJj5HOgs+c2mGINhf4CPVa5tMt8+zZvk7O0cGyC6mb4x463gQxzOFuEgFXZBawCnXSS854uzQebpkHLqXgKXkR7QPR31Kxw==
    """
    
    static let serverCertPublicKeyBase64String = """
    MIIBCgKCAQEA5PDJy7rRYJBOrDm2WSMsQa6tk+xd2k8pG8rC+fT5GUSKQt8ifqLau82wDgGetPNU6YxUXN80LvQABFrLMQ3YGSmcSGFsTXthINribc3LVJqR93lcky2mGaxIhcFXU0HgnIPiTywGfZ7HYwCrCHHAeOPrOBjAF8QSbUJbKM1HfzGgL1H4607JkRCtW7tkRK2gb5TG0sjUnjvCZSNHdaR55jpDO9D3L4+RVBCMde5Cd8X8pB7VbWWv2mVF4ElS8p057j1RqTYzVZH8Ps/PbGygCXfOXu1P5FfOr8KDiml5xa3GITPK9ubUoGoZhCPr/APu7zY46oAzSClPM22zMcwq2wIDAQAB
    """
    
    static let serverDecryptedPublicKeyBase64String = """
    BIa4M5uH1HRw9HxZwO45PgBYS3FvYsGJHYQVFiRqU8W7Sl0XV88wgF4SDBLKuLVYjMXJYJrlKBgA1xXDt/cvEhHhthSHqvPgtBwzUSTVUbIo8yI0ZSNo0Hijot53FkXtHQ==
    """
    static let sharedSecretKeyBase64String = """
    zSz5E2C8Zl82B/j6vCyidofXzqA+9WkMG2s5LT0w1oc=
    """
}

extension CSRFAgentTests {
    
    struct KeysProviderMock: EncryptionKeysProvider {

        let publcKey: SecKey
        let privateKey: SecKey
        
        init(publcKey: SecKey, privateKey: SecKey) {
            
            self.publcKey = publcKey
            self.privateKey = privateKey
        }
        
        func generateKeysPair() throws -> EncryptionKeysPair {
            
            return .init(publicKey: publcKey, privateKey: privateKey)
        }
    }
    
    struct KeysProviderEmptyMock: EncryptionKeysProvider {

        func generateKeysPair() throws -> EncryptionKeysPair {
            
            throw TestError.keyPairGenerationNotExpected
        }
    }
    
    func externalKeyData(from key: SecKey) throws -> Data {
    
        var error: Unmanaged<CFError>? = nil
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            throw TestError.failedCreationExternalKeyRepresentation(error?.takeRetainedValue())
        }

        return keyData
    }
    
    func createSecKey(from keyBase64String: String, type: KeyType) throws -> SecKey {
        
        guard let keyData = Data(base64Encoded: keyBase64String, options: .ignoreUnknownCharacters) as CFData? else {
            throw TestError.failedDecodingKeyDataFromBase64String
        }
        
        let parameters = type.parameters
        
        var error: Unmanaged<CFError>? = nil
        guard let key = SecKeyCreateWithData(keyData, parameters, &error) else {
            throw TestError.failedCreatingSecKeyFromData(error?.takeRetainedValue())
        }
        
        return key
    }
    
    enum KeyType {
        
        case `public`
        case `private`
        
        var parameters: CFDictionary {
            
            switch self {
            case .public:
                return [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                        kSecAttrKeySizeInBits as String : 384,
                        SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32] as CFDictionary
                
            case .private:
                return [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                        kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                        kSecAttrKeySizeInBits as String : 384,
                        SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32] as CFDictionary
            }
        }
        
    }
    
    enum TestError: Swift.Error {
        
        case keyPairGenerationNotExpected
        case failedCreationExternalKeyRepresentation(Error?)
        case failedDecodingKeyDataFromBase64String
        case failedCreatingSecKeyFromData(Error?)
    }
}

