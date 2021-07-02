//
//  RouterManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum RouterManager {
    case login
    case setDeviceSetting
    case csrf
    case checkCkient
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
}

extension RouterManager {
    func request() -> URLRequest? {
        let resultUrl: URL?
        switch self {
        case .login:
            let baseUrl = RouterUrlList.login.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        
        case .setDeviceSetting:
            let baseUrl = RouterUrlList.setDeviceSetting.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        
        case .csrf:
            let baseUrl = RouterUrlList.csrf.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .checkCkient:
            let baseUrl = RouterUrlList.chackClient.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .verifyCode:
            let baseUrl = RouterUrlList.verifyCode.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .doRegistration:
            let baseUrl = RouterUrlList.doRegistration.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCode:
            let baseUrl = RouterUrlList.getCode.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        case .installPushDevice:
            let baseUrl = RouterUrlList.installPushDevice.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .registerPushDeviceForUser:
            let baseUrl = RouterUrlList.registerPushDeviceForUser.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .uninstallPushDevice:
            let baseUrl = RouterUrlList.uninstallPushDevice.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCardList:
            let baseUrl = RouterUrlList.getCardList.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .keyExchange:
            let baseUrl = RouterUrlList.keyExchange.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCountries:
            let baseUrl = RouterUrlList.getCountries.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .anywayPaymentBegin:
            let baseUrl = RouterUrlList.anywayPaymentBegin.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .anywayPaymentMake:
            let baseUrl = RouterUrlList.anywayPaymentMake.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .anywayPayment:
            let baseUrl = RouterUrlList.anywayPayment.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .prepareCard2Phone:
            let baseUrl = RouterUrlList.prepareCard2Phone.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getOwnerPhoneNumber:
            let baseUrl = RouterUrlList.getOwnerPhoneNumber.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .fastPaymentBanksList:
            let baseUrl = RouterUrlList.fastPaymentBanksList.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .makeCard2Card:
            let baseUrl = RouterUrlList.makeCard2Card.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getLatestPayments:
            let baseUrl = RouterUrlList.getLatestPayments.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .getPrintForm:
            let baseUrl = RouterUrlList.getPrintForm.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getLatestPhonePayments:
            let baseUrl = RouterUrlList.getLatestPhonePayments.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .createTransfer:
            let baseUrl = RouterUrlList.createTransfer.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .makeTransfer:
            let baseUrl = RouterUrlList.makeTransfer.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getBanks:
            let baseUrl = RouterUrlList.getBanks.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .getPaymentSystemList:
            let baseUrl = RouterUrlList.getPaymentSystemList.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .getProductList:
            let baseUrl = RouterUrlList.getProductList.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getVerificationCode:
            let baseUrl = RouterUrlList.getVerificationCode.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .prepareExternal:
            let baseUrl = RouterUrlList.prepareExternal.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getExchangeCurrencyRates:
            let baseUrl = RouterUrlList.getExchangeCurrencyRates.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        }
    }
}

