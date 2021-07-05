//
//  RouterUrlList.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum RouterUrlList: String {
    
    public typealias URLValue = Result<URL, RouterError>
    
    /// Авторизация
    case login
    /// Авторизация приложения
    case setDeviceSetting
    /// Получение токена при запуске приложения
    case csrf
    case chackClient
    case verifyCode
    case doRegistration
    case getCode
    case installPushDevice
    case registerPushDeviceForUser
    case uninstallPushDevice
    case getCardList
    case keyExchange
    case getCountries
    case anywayPaymentBegin
    case anywayPaymentMake
    case anywayPayment
    case prepareCard2Phone
    case getOwnerPhoneNumber
    case fastPaymentBanksList
    case makeCard2Card
    case getLatestPayments
    case getPrintForm
    case getLatestPhonePayments
    case createTransfer
    case makeTransfer
    case getBanks
    case getPaymentSystemList
    case getProductList
    case getVerificationCode
    case prepareExternal
    case getExchangeCurrencyRates
    case suggestBank
    
    func returnUrl () -> URLValue {
        switch self {
        /// Авторизация
        case .login:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.login.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }

        /// Авторизация приложения
        case .setDeviceSetting:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.setDeviceSettting.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        /// Получение токена при запуске приложения
        case .csrf:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.csrf.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .chackClient:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.checkClient.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .verifyCode:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.verifyCode.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .doRegistration:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.doRegistration.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getCode:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getCode.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .installPushDevice:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.installPushDevice.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .registerPushDeviceForUser:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.registerPushDeviceForUser.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .uninstallPushDevice:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.uninstallPushDevice.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getCardList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getCardList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .keyExchange:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.keyExchange.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getCountries:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getCountries.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .anywayPaymentBegin:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.anywayPaymentBegin.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .anywayPaymentMake:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.anywayPaymentMake.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .anywayPayment:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.anywayPayment.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .prepareCard2Phone:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.prepareCard2Phone.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getOwnerPhoneNumber:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getOwnerPhoneNumber.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .fastPaymentBanksList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.fastPaymentBanksList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .makeCard2Card:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.makeCard2Card.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getLatestPayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getLatestPayments.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getPrintForm:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getPrintForm.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getLatestPhonePayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getLatestPhonePayments.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .makeTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.makeTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getBanks:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getBanks.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getPaymentSystemList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getPaymentSystemList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getProductList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getProductList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getVerificationCode:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getVerificationCode.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .prepareExternal:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.prepareExternal.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getExchangeCurrencyRates:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getExchangeCurrencyRates.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .suggestBank:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.suggestBank.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        }
    }
}
