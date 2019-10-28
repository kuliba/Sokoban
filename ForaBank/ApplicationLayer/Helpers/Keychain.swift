//
//  Keychain.swift
//  ForaBank
//
//  Created by Бойко Владимир on 28.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import KeychainAccess

func removeAllKeychainItems() {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    _ = keychain.allKeys().map({ keychain[$0] = nil })
}

// Храним Логи/Пароль в шифрованном виде
func keychainCredentialsUserData() -> String? {
    return Keychain(service: KeychainConstants.serviceName)["userData"]
}

// Храним пасскод в шифрованном виде
func keychainCredentialsEncryptedPasscode() -> String? {
    return Keychain(service: KeychainConstants.serviceName)["encryptedPasscode"]
}

// Храним пасскод в открытом виде
func keychainCredentialsPasscode() -> String? {
    return Keychain(service: KeychainConstants.serviceName)["passcode"]
}

func saveUserDataToKeychain(userData: String) {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    keychain["userData"] = userData
}

func saveEncryptedPasscodeToKeychain(passcode: String) {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    keychain["encryptedPasscode"] = passcode
}

func savePasscodeToKeychain(passcode: String) {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    keychain["passcode"] = passcode
}

func unsafeRemoveEncryptedPasscodeFromKeychain() {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    try! keychain.remove("encryptedPasscode")
}

func unsafeRemovePasscodeFromKeychain() {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    try! keychain.remove("passcode")
}

func unsafeRemoveUserDataFromKeychain() {
    let keychain = Keychain(service: KeychainConstants.serviceName)
    try! keychain.remove("userData")
}
