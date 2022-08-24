//
//  UserSettingData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct UserSettingData: Codable, Equatable {
    
    let name: String?
    let sysName: String
    let value: String
}

extension UserSettingData {
    
    enum Kind: String {
        
        case disablePush = "DisablePush"
    }
}

protocol UserSettingProtocol {
    
    associatedtype Value
    
    var type: UserSettingData.Kind { get }
    var value: Value { get }

    var rawValue: String { get }
    
    var userSettingData: UserSettingData { get }
    init?(with userSettingData: UserSettingData)
}

extension UserSettingProtocol {
    
    var userSettingData: UserSettingData { UserSettingData(name: nil, sysName: type.rawValue, value: rawValue) }
}

struct UserSettingPush: UserSettingProtocol {

    let type: UserSettingData.Kind = .disablePush
    let value: Bool
    var rawValue: String { value ? "0" : "1" }

    internal init(value: Bool) {
        self.value = value
    }
    
    init?(with userSettingData: UserSettingData) {
        
        guard userSettingData.sysName == UserSettingData.Kind.disablePush.rawValue else {
            return nil
        }
        
        self.init(value: userSettingData.value == "0")
    }
}

