//
//  SettingType.swift
//  Vortex
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

enum SettingType: Equatable {
    
    case general(General)
    case transfers(Transfers)
    case security(Security)
    case interface(Interface)
        
    enum General: String {
        
        case launchedBefore
    }
    
    enum Transfers: String {
        
        case sfp
    }
    
    enum Security: String {
        
        case sensor
        case push
        case block
    }
    
    enum Interface {
        
        case mainSections
        case inactiveProducts
        case paymentTemplates
        case productsHidden
        case productsSections
        case productsMoney
        case myProductsOnboarding
        case creditCardMVP
        case sticker
        case savingsAccount
        case profileOnboarding
        case collateralLoan(CollateralLoanType)
    }
}

extension SettingType {
    
    var identifier: String {
        
        switch self {
        case let .general(general):
            return "setting_general_\(general.rawValue)"
            
        case let .transfers(transfers):
            return "setting_transfers_\(transfers.rawValue)"
            
        case let .security(security):
            return "setting_security_\(security.rawValue)"
            
        case let .interface(interface):
            return "setting_interface_\(interface.rawValue)"
        }
    }
}

extension SettingType: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        switch self {
        case .general(let value): return "general : \(value.rawValue)"
        case .transfers(let value): return "transfers : \(value.rawValue)"
        case .security(let value): return "security : \(value.rawValue)"
        case .interface(let value): return "interface : \(value.rawValue)"
        }
    }
}

extension SettingType.Interface {
    
    var rawValue: String {
        
        switch self {
        case .mainSections:
            return .mainSections
            
        case .inactiveProducts:
            return .inactiveProducts
            
        case .paymentTemplates:
            return .paymentTemplates
            
        case .productsHidden:
            return .productsHidden
            
        case .productsSections:
            return .productsSections
            
        case .productsMoney:
            return .productsMoney
            
        case .myProductsOnboarding:
            return .myProductsOnboarding
            
        case .sticker:
            return .sticker
            
        case .savingsAccount:
            return .savingsAccount
            
        case .profileOnboarding:
            return .profileOnboarding
            
        case let .collateralLoan(type):
            switch type {
            case .showcase:
                return .collateralLoanShowcase
                
            case .car:
                return .collateralLoanCar
                
            case .realEstate:
                return .collateralLoanRealEstate
            }
            
        case .creditCardMVP:
            return .creditCardMVP
        }
    }
}

extension SettingType.Interface: Equatable {}

private extension String {
    
    static let collateralLoanCar = "collateralLoanCar"
    static let collateralLoanRealEstate = "collateralLoanRealEstate"
    static let collateralLoanShowcase = "collateralLoanShowcase"
    static let creditCardMVP = "creditCardMVP"
    static let inactiveProducts = "inactiveProducts"
    static let mainSections = "mainSections"
    static let myProductsOnboarding = "myProductsOnboarding"
    static let paymentTemplates = "paymentTemplates"
    static let productsHidden = "productsHidden"
    static let productsMoney = "productsMoney"
    static let productsSections = "productsSections"
    static let profileOnboarding = "profileOnboarding"
    static let savingsAccount = "savingsAccount"
    static let sticker = "sticker"
}
