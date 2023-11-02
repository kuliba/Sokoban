//
//  LoggingCVVPINJSONMakerDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CVVPIN_Services
import ForaCrypto
import Foundation

final class LoggingCVVPINJSONMakerDecorator {
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    private let decoratee: CVVPINJSONMaker
    private let debugLog: Log
    private let logError: Log

    init(
        decoratee: CVVPINJSONMaker,
        debugLog: @escaping Log,
        logError: @escaping Log
    ) {
        self.decoratee = decoratee
        self.debugLog = debugLog
        self.logError = logError
    }
}

extension LoggingCVVPINJSONMakerDecorator: CVVPINJSONMaker {
    
    func makeRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey,
        rsaKeyPair: RSAKeyPair
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeRequestJSON(
                publicKey: publicKey,
                rsaKeyPair: rsaKeyPair
            )
            debugLog("Make JSON success: \"\(String(data: json, encoding: .utf8) ?? "n/a")\"", #file, #line)
            
            return json
        } catch {
            logError("Make JSON failure: \(error.localizedDescription)", #file, #line)
            throw error
        }
    }
    
    func makeSecretJSON(
        otp: String,
        sessionKey: SessionKey
    ) throws -> (
        data: Data,
        keyPair: RSAKeyPair
    ) {
        do {
            let output = try decoratee.makeSecretJSON(
                otp: otp,
                sessionKey: sessionKey
            )
            debugLog("Make Secret JSON success (data: \(output.data.count)).", #file, #line)
            
            return output
        } catch {
            logError("Make Secret JSON failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func makeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeSecretRequestJSON(publicKey: publicKey)
            debugLog("Secret Request JSON creation success: \(json)", #file, #line)
            
            return json
        } catch {
            logError("Secret Request JSON creation failure: \(error)", #file, #line)
            throw error
        }
    }
    
    func makePINChangeJSON(
        sessionID: ChangePINService.SessionID,
        cardID: ChangePINService.CardID,
        otp: ChangePINService.OTP,
        pin: ChangePINService.PIN,
        otpEventID: ChangePINService.OTPEventID,
        sessionKey: SessionKey,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makePINChangeJSON(
                sessionID: sessionID,
                cardID: cardID,
                otp: otp,
                pin: pin,
                otpEventID: otpEventID,
                sessionKey: sessionKey,
                rsaPrivateKey: rsaPrivateKey
            )
            debugLog("Make Change PIN JSON success: \(json)", #file, #line)
            
            return json
        } catch {
            logError("Make Change PIN JSON failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func makeSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        rsaKeyPair: RSAKeyPair,
        sessionKey: SessionKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeSecretJSON(
                with: cardID,
                and: sessionID,
                rsaKeyPair: rsaKeyPair,
                sessionKey: sessionKey
            )
            debugLog("SecretJSON creation success (\(json.count)).", #file, #line)
            
            return json
        } catch {
            logError("SecretJSON creation failure: \(error).", #file, #line)
            throw error
        }
    }
}
