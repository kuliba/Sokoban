//
//  RouterManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation
import SwiftUI

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
    case suggestCompany
    case getCurrencyList
    case getProductTemplateList
    case deleteProductTemplate
    case checkCard
    case logout
    case getPaymentCountries
    case getProductListByFilter
    case getAnywayOperatorsList
    case getFullBankInfoList
    case createServiceTransfer
    case createInternetTransfer
    case antiFraud
    case createMe2MePullCreditTransfer
    case createFastPaymentContract
    case updateFastPaymentContract
    case fastPaymentContractFindList
    case createContactAddresslessTransfer
    case createDirectTransfer
    case getClientConsentMe2MePull
    case changeClientConsentMe2MePull
    case getLatestServicePayments
    case getLatestInternetTVPayments
    case getLatestInternetTVPaymentsTransport
    case createSFPTransfer
    case createIsOneTimeConsentMe2MePull
    case createPermanentConsentMe2MePull
    case isLogin
    case createMe2MePullDebitTransfer
    case getMe2MeDebitConsent
    case getCardStatement
    case getDepositStatement
    case saveCardName
    case blockCard
    case unblockCard
    case getProductDetails
    case setUserSetting
    case getUserSettings
    case getPhoneInfo
    case createMobileTransfer
    case getSessionTimeout
    case getAccountStatement
    case getLatestMobilePayments
    case getMobileList
    case getAllLatestPayments
    case getOperationDetail
    case getNotifications
    case getPrintFormForAccountStatement
    case isSingleService
    case getClientInfo
    case getMosParkingList
    case getDepositInfo
    case nextStepServiceTransfer
    case createAnywayTransfer
    case createAnywayTransferNew
    case getDepositProductList
    case openDeposit
    case makeDepositPayment
    case changeOutgoing
    case returnOutgoing
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
            
        case .suggestBank:
            let baseUrl = RouterUrlList.suggestBank.returnUrl()
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
            
        case .suggestCompany:
            let baseUrl = RouterUrlList.suggestCompany.returnUrl()
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
            
        case .getCurrencyList:
            let baseUrl = RouterUrlList.getCurrencyList.returnUrl()
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
            
        case .getProductTemplateList:
            let baseUrl = RouterUrlList.getProductTemplateList.returnUrl()
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
            
        case .deleteProductTemplate:
            let baseUrl = RouterUrlList.deleteProductTemplate.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.delete.rawValue
            return request
            
        case .checkCard:
            let baseUrl = RouterUrlList.checkCard.returnUrl()
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
            
        case .logout:
            let baseUrl = RouterUrlList.logout.returnUrl()
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
            
        case .getPaymentCountries:
            let baseUrl = RouterUrlList.getPaymentCountries.returnUrl()
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
            
        case .getProductListByFilter:
            let baseUrl = RouterUrlList.getProductListByFilter.returnUrl()
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
            
        case .getAnywayOperatorsList:
            let baseUrl = RouterUrlList.getAnywayOperatorsList.returnUrl()
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
            
        case .getFullBankInfoList:
            let baseUrl = RouterUrlList.getFullBankInfoList.returnUrl()
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
            
        case .createServiceTransfer:
            let baseUrl = RouterUrlList.createServiceTransfer.returnUrl()
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

        case .createInternetTransfer:
            let baseUrl = RouterUrlList.createInternetTransfer.returnUrl()
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

        case .antiFraud:
            let baseUrl = RouterUrlList.antiFraud.returnUrl()
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
            
        case .createMe2MePullCreditTransfer:
            let baseUrl = RouterUrlList.createMe2MePullCreditTransfer.returnUrl()
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
            
        case .createFastPaymentContract:
            let baseUrl = RouterUrlList.createFastPaymentContract.returnUrl()
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
            
        case .updateFastPaymentContract:
            let baseUrl = RouterUrlList.updateFastPaymentContract.returnUrl()
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
            
        case .fastPaymentContractFindList:
            let baseUrl = RouterUrlList.fastPaymentContractFindList.returnUrl()
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
            
        case .createContactAddresslessTransfer:
            let baseUrl = RouterUrlList.createContactAddresslessTransfer.returnUrl()
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
            
        case .createDirectTransfer:
            let baseUrl = RouterUrlList.createDirectTransfer.returnUrl()
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
            
        case .getClientConsentMe2MePull:
            let baseUrl = RouterUrlList.getClientConsentMe2MePull.returnUrl()
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
            
        case .changeClientConsentMe2MePull:
            let baseUrl = RouterUrlList.changeClientConsentMe2MePull.returnUrl()
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
            
            
        case .getLatestServicePayments:
            let baseUrl = RouterUrlList.getLatestServicePayments.returnUrl()
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

        case .getLatestInternetTVPayments:
            let baseUrl = RouterUrlList.getLatestInternetTVPayments.returnUrl()
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

        case .getLatestInternetTVPaymentsTransport:
            let baseUrl = RouterUrlList.getLatestInternetTVPaymentsTransport.returnUrl()
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

        case .createSFPTransfer:
            let baseUrl = RouterUrlList.createSFPTransfer.returnUrl()
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
            
        case .createIsOneTimeConsentMe2MePull:
            let baseUrl = RouterUrlList.createIsOneTimeConsentMe2MePull.returnUrl()
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
            
        case .createPermanentConsentMe2MePull:
            let baseUrl = RouterUrlList.createPermanentConsentMe2MePull.returnUrl()
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
            
        case .isLogin:
            let baseUrl = RouterUrlList.isLogin.returnUrl()
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
        
        case .createMe2MePullDebitTransfer:
            let baseUrl = RouterUrlList.createMe2MePullDebitTransfer.returnUrl()
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
            
        case .getMe2MeDebitConsent:
            let baseUrl = RouterUrlList.getMe2MeDebitConsent.returnUrl()
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
            
        case .getCardStatement:
            let baseUrl = RouterUrlList.getCardStatement.returnUrl()
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
            
        case .getDepositStatement:
            let baseUrl = RouterUrlList.getDepositStatement.returnUrl()
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
            
        case .saveCardName:
            let baseUrl = RouterUrlList.saveCardName.returnUrl()
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
            
        case .blockCard:
            let baseUrl = RouterUrlList.blockCard.returnUrl()
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
            
        case .unblockCard:
            let baseUrl = RouterUrlList.unblockCard.returnUrl()
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
            
        case .getProductDetails:
            let baseUrl = RouterUrlList.getProductDetails.returnUrl()
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
            
        case .setUserSetting:
            let baseUrl = RouterUrlList.setUserSetting.returnUrl()
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
            
        case .getUserSettings:
            let baseUrl = RouterUrlList.getUserSettings.returnUrl()
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
            
        case .getPhoneInfo:
            let baseUrl = RouterUrlList.getPhoneInfo.returnUrl()
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
            
        case .createMobileTransfer:
            let baseUrl = RouterUrlList.createMobileTransfer.returnUrl()
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
            
            //getSessionTimeout
        case .getSessionTimeout:
            let baseUrl = RouterUrlList.getSessionTimeout.returnUrl()
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
            
        case .getAccountStatement:
            let baseUrl = RouterUrlList.getAccountStatement.returnUrl()
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
            
        case .getLatestMobilePayments:
            let baseUrl = RouterUrlList.getLatestMobilePayments.returnUrl()
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
            
        case .getMobileList:
            let baseUrl = RouterUrlList.getMobileList.returnUrl()
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
            
        case .getAllLatestPayments:
            let baseUrl = RouterUrlList.getAllLatestPayments.returnUrl()
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
        case .getOperationDetail:
            let baseUrl = RouterUrlList.getOperationDetail.returnUrl()
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
            
        case .getDepositInfo:
            let baseUrl = RouterUrlList.getDepositInfo.returnUrl()
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
            
            
        case .getNotifications:
            let baseUrl = RouterUrlList.getNotifications.returnUrl()
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
            
        case .getPrintFormForAccountStatement:
            let baseUrl = RouterUrlList.getPrintFormForAccountStatement.returnUrl()
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
            
        case .isSingleService:
            let baseUrl = RouterUrlList.isSingleService.returnUrl()
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

        case .getMosParkingList:
            let baseUrl = RouterUrlList.getMosParkingList.returnUrl()
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

        case .getClientInfo:
            let baseUrl = RouterUrlList.getClientInfo.returnUrl()
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
            
        case .nextStepServiceTransfer:
            let baseUrl = RouterUrlList.nextStepServiceTransfer.returnUrl()
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

        case .createAnywayTransfer:
            let baseUrl = RouterUrlList.createAnywayTransfer.returnUrl()
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

        case .createAnywayTransferNew:
            let baseUrl = RouterUrlList.createAnywayTransferNew.returnUrl()
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
            
        case .getDepositProductList:
            let baseUrl = RouterUrlList.getDepositProductList.returnUrl()
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
            
        case .openDeposit:
            let baseUrl = RouterUrlList.openDeposit.returnUrl()
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
            
        case .makeDepositPayment:
            let baseUrl = RouterUrlList.makeDepositPayment.returnUrl()
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
            
        case .changeOutgoing:
            let baseUrl = RouterUrlList.changeOutgoing.returnUrl()
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
            
        case .returnOutgoing:
            let baseUrl = RouterUrlList.returnOutgoing.returnUrl()
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

