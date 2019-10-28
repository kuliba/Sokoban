//
//  Security.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import CryptoSwift

typealias UserData = (login: String, pwd: String)

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement() ?? "a" })
}

//Passcode - crypto

func encrypt(userData: UserData, withPasscode passcode: String) -> String? {
    guard passcode.count > 0 else {
        return nil
    }
    let userData = "\(userData.login)+\(userData.pwd)"
    let key = aesKey32Dumb(with: passcode)
    let iv = aesInitializationVector16Dump()
    return try! userData.aesEncrypt(withKey: key, iv: iv)
}

func decryptUserData(userData: String, withPossiblePasscode possiblePasscode: String) -> UserData? {
    let key = aesKey32Dumb(with: possiblePasscode)
    let iv = aesInitializationVector16Dump()
    let decryptedUserData = try! userData.aesDecrypt(withKey: key, iv: iv)

    let userDataStrings = decryptedUserData?.components(separatedBy: "+")
    guard let login = userDataStrings?[0], let pwd = userDataStrings?[1] else {
        return nil
    }
    return UserData(login: login, pwd: pwd)
}

//Passcode - crypto

func encrypt(passcode: String) -> String? {
    let key = aesKey32Dumb(with: passcode)
    let iv = aesInitializationVector16Dump()
    return try! passcode.aesEncrypt(withKey: key, iv: iv)
}

func decryptPasscode(withPossiblePasscode possiblePasscode: String) -> String? {
    let key = aesKey32Dumb(with: possiblePasscode)
    let iv = aesInitializationVector16Dump()
    let encryptedPasscode = keychainCredentialsPasscode()

    return try! encryptedPasscode?.aesDecrypt(withKey: key, iv: iv)
}

//Crypto

func aesKey32Addition(with string: String) -> String {
    return randomString(length: 32 - string.count)
}

func aesKey32Dumb(with string: String) -> String {
    return string + String(repeating: "0", count: 32 - string.count)
}

func aesKey32(with string: String) -> String {
    return string + randomString(length: 32 - string.count)
}

func aesInitializationVector16Random() -> String {
    return randomString(length: 16)
}

func aesInitializationVector16Dump() -> String {
    return String(repeating: "0", count: 16)
}

extension String {
    func aesEncrypt(withKey key: String, iv: String) throws -> String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let encrypted = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](data))
        return Data(encrypted).base64EncodedString()
    }

    func aesDecrypt(withKey key: String, iv: String) throws -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        let decrypted = try AES(key: key, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
        return String(bytes: decrypted, encoding: .utf8)
    }
}
