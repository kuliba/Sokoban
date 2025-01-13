//
//  ExamplesDataToFormat.swift
//
//
//  Created by Andryusina Nataly on 19.10.2023.
//

import Foundation

/// A namespace for the PhoneNumber.

enum ExamplesDataToFormat {
    
    case am(AM)
    case ru(RU)
    case tr(TR)
    case us(US)
    case otherNotValid(OtherNotValid)
    case empty
    case custom(String)
    
    var typeName: String {
        switch self {
        case .am:            return "Armenia"
        case .ru:            return "Russia"
        case .tr:            return "Turkey"
        case .us:            return "US"
        case .otherNotValid: return "OtherNotValid"
        case .empty:         return "Empty"
        case .custom:        return "Сustom"
        }
    }
    
    var phone: String {
        switch self {
        case let .am(value):            return value.phone
        case let .ru(value):            return value.phone
        case let .tr(value):            return value.phone
        case let .us(value):            return value.rawValue
        case let .otherNotValid(value): return value.rawValue
        case .empty:                    return ""
        case let .custom(value):        return value
        }
    }
}


extension ExamplesDataToFormat {
    // 10Digits - считается без кода страны (7/8)
    enum RU {
        
        case startsWith7(StartsWith7)
        case startsWithPlus7(StartsWithPlus7)
        case startsWith8(StartsWith8)
        case startsWithPlus8(StartsWithPlus8)
        case startsWith9(StartsWith9)
        case startsWith982(StartsWith982)
        case startsWithZero(StartsWithZero)
        
        enum StartsWith8: String {
            case equals10Digits = "89630000000"
            case lessThen10Digits = "8963000000"
            case moreThen10Digits = "896300000000"
        }
        
        enum StartsWithPlus8: String {
            case equals10Digits = "+89630000000"
            case lessThen10Digits = "+8963000000"
            case moreThen10Digits = "+896300000000"
        }
        
        enum StartsWith7: String {
            case equals10Digits = "79630000000"
            case equals10DigitsWith7982 = "79820000000"
            case lessThen10Digits = "79630000"
            case moreThen10Digits = "796300000000"
        }
        
        enum StartsWithPlus7: String {
            case equals10Digits = "+79630000000"
            case equals10DigitsWith7982 = "+79820000000"
            case lessThen10Digits = "+7963000000"
            case moreThen10Digits = "+796300000000"
        }
        
        enum StartsWithZero: String {
            case equals10DigitsNotValid = "00796300000"
            case lessThen10DigitsNotValid = "00796300"
            case moreThen10DigitsValid = "0079630000000"
            case moreThen10DigitsValidWith7982 = "0079820000000"
            case moreThen10DigitsNotValid = "0000796300000"
        }
        
        enum StartsWith9: String {
            case equals10Digits = "9630000000"
            case lessThen10Digits = "963000000"
            case moreThen10Digits = "96300000000"
        }
        
        enum StartsWith982: String {
            case equals10Digits = "9820000000"
            case lessThen10Digits = "982000000"
            case moreThen10Digits = "98200000000"
        }

        var phone: String {
            switch self {
            case let .startsWith7(phone):
                return phone.rawValue
            case let .startsWithPlus7(phone):
                return phone.rawValue
            case let .startsWith8(phone):
                return phone.rawValue
            case let .startsWithPlus8(phone):
                return phone.rawValue
            case let .startsWith9(phone):
                return phone.rawValue
            case let .startsWithZero(phone):
                return phone.rawValue
            case let .startsWith982(phone):
                return phone.rawValue
            }
        }
    }
}

extension ExamplesDataToFormat {
    // Армения 8Digits - считается без кода страны (374)
    enum AM {
        
        case startsWith374(StartsWith374)
        case startsWithPlus374(StartsWithPlus374)
        case startsWithZero(StartsWithZero)
        
        enum StartsWith374: String {
            case equals8Digits = "37411222333"
            case lessThen8Digits = "3741122233"
            case moreThen8Digits = "3741122233322"
        }
        
        enum StartsWithPlus374: String {
            case equals8Digits = "+37411222333"
            case lessThen8Digits = "+3741122233"
            case moreThen8Digits = "+3741122233322"
        }
        
        enum StartsWithZero: String {
            case equals8DigitsNotValid = "00374112223"
            case lessThen8DigitsNotValid = "00374112"
            case moreThen8DigitsValid = "0037411222333"
            case moreThen8DigitsNotValid = "00003741122"
        }
        
        var phone: String {
            switch self {
                
            case let .startsWith374(phone):
                return phone.rawValue
            case let .startsWithPlus374(phone):
                return phone.rawValue
            case let .startsWithZero(phone):
                return phone.rawValue
            }
        }
    }
}

extension ExamplesDataToFormat {
    // Турция 10Digits - считается без кода страны (90)
    enum TR {
        
        case startsWith90(StartsWith90)
        case startsWithPlus90(StartsWithPlus90)
        case startsWithZero(StartsWithZero)
        
        enum StartsWith90: String {
            case equals10Digits = "905311234567"
            case lessThen10Digits = "90531123456"
            case moreThen10Digits = "9053112345671"
        }
        
        enum StartsWithPlus90: String {
            case equals10Digits = "+905311234567"
            case lessThen10Digits = "+90531123456"
            case moreThen10Digits = "+9053112345671"
        }
        
        enum StartsWithZero: String {
            case equals10DigitsNotValid = "009053112345"
            case lessThen10DigitsNotValid = "0090531"
            case moreThen10DigitsValid = "00905311234567"
            case moreThen10DigitsNotValid = "0000905311239"
        }
        
        var phone: String {
            switch self {
            case let .startsWith90(phone):
                return phone.rawValue
            case let .startsWithPlus90(phone):
                return phone.rawValue
            case let .startsWithZero(phone):
                return phone.rawValue
            }
        }
    }
}

extension ExamplesDataToFormat {
    
    enum US: String {
        
        case withPlus = "+18004699269"
        case withOutPlus = "18004699269"
        case startsWithZeroValid = "00018004699269"
        case startsWithZeroNotValid = "000180046992692"
    }
}

extension ExamplesDataToFormat {
    
    enum OtherNotValid: String {
        
        case longArmenia = "37411122233344455566"
        case longLuxembourg = "35211122233344455566"
        case longPhilippines = "63121545454542121"
        case longTurkey = "901213121545454545454"
        case longIran =  "98920555085654545454"
        case longUSA = "1232545454545444"
        case short = "+11223"
    }
}
