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
    
    private let decoratee: CVVPINJSONMaker
    private let log: (String) -> Void
    
    init(
        decoratee: CVVPINJSONMaker,
        log: @escaping (String) -> Void
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
            log("Make JSON success: \"\(String(data: json, encoding: .utf8) ?? "n/a")\"")
            
            return json
        } catch {
            log("Make JSON failure: \(error.localizedDescription)")
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
            log("Make Secret JSON success (data: \(output.data.count)).")
            
            return output
        } catch {
            log("Make Secret JSON failure: \(error).")
            throw error
        }
    }
    
    func makeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        do {
            let json = try decoratee.makeSecretRequestJSON(publicKey: publicKey)
            log("Secret Request JSON creation success: \(json)")
            
            return json
        } catch {
            log("Secret Request JSON creation failure: \(error)")
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
            log("Make Change PIN JSON success: \(json)")
            
            return json
        } catch {
            log("Make Change PIN JSON failure: \(error).")
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
            log("SecretJSON creation success (\(json.count)).")
            
            return json
        } catch {
            log("SecretJSON creation failure: \(error).")
            throw error
        }
    }
}
