//
//  LoggingCVVPINJSONMakerDecorator.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CVVPIN_Services
import VortexCrypto
import Foundation

final class LoggingCVVPINJSONMakerDecorator {
    
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void

    private let decoratee: CVVPINJSONMaker
    private let log: Log

    init(
        decoratee: CVVPINJSONMaker,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
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
            log(.debug, "Make JSON success: \"\(String(data: json, encoding: .utf8) ?? "n/a")\"", #file, #line)
            
            return json
        } catch {
            log(.error, "Make JSON failure: \(error.localizedDescription)", #file, #line)
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
            log(.debug, "Make Secret JSON success (data: \(output.data.count)).", #file, #line)
            
            return output
        } catch {
            log(.error, "Make Secret JSON failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func makeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeSecretRequestJSON(publicKey: publicKey)
            log(.debug, "Secret Request JSON creation success: \(json)", #file, #line)
            
            return json
        } catch {
            log(.error, "Secret Request JSON creation failure: \(error)", #file, #line)
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
            log(.debug, "Make Change PIN JSON success: \(json)", #file, #line)
            
            return json
        } catch {
            log(.error, "Make Change PIN JSON failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func makeShowCVVSecretJSON(
        with cardID: ShowCVVService.CardID,
        and sessionID: ShowCVVService.SessionID,
        rsaKeyPair: RSAKeyPair,
        sessionKey: SessionKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeShowCVVSecretJSON(
                with: cardID,
                and: sessionID,
                rsaKeyPair: rsaKeyPair,
                sessionKey: sessionKey
            )
            log(.debug, "SecretJSON creation success (\(json.count)).", #file, #line)
            
            return json
        } catch {
            log(.error, "SecretJSON creation failure: \(error).", #file, #line)
            throw error
        }
    }
}
