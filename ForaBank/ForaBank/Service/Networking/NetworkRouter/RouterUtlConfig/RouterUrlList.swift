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
    case createSFPTransfer
    case createIsOneTimeConsentMe2MePull
    case createPermanentConsentMe2MePull
    case isLogin
    case createMe2MePullDebitTransfer
    case getMe2MeDebitConsent
    case getCardStatement
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
            
        case .suggestCompany:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.suggestCompany.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getCurrencyList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getCurrencyList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getProductTemplateList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getProductTemplateList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .deleteProductTemplate:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.deleteProductTemplate.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .checkCard:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.checkCard.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .logout:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.logout.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getPaymentCountries:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getPaymentCountries.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getProductListByFilter:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getProductListByFilter.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getAnywayOperatorsList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getAnywayOperatorsList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getFullBankInfoList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getFullBankInfoList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createServiceTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createServiceTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }

        case .createInternetTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createInternetTransfer.rawValue)

            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .antiFraud:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.antiFraud.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createMe2MePullCreditTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createMe2MePullCreditTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createFastPaymentContract:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createFastPaymentContract.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .updateFastPaymentContract:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.updateFastPaymentContract.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .fastPaymentContractFindList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.fastPaymentContractFindList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createContactAddresslessTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createContactAddresslessTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        
        case .createDirectTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createDirectTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .getClientConsentMe2MePull:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getClientConsentMe2MePull.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .changeClientConsentMe2MePull:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.changeClientConsentMe2MePull.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getLatestServicePayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getLatestServicePayments.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .getLatestInternetTVPayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getLatestInternetTVPayments.rawValue)
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .createSFPTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createSFPTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createIsOneTimeConsentMe2MePull:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createIsOneTimeConsentMe2MePull.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createPermanentConsentMe2MePull:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createPermanentConsentMe2MePull.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .isLogin:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.isLogin.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .createMe2MePullDebitTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createMe2MePullDebitTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getMe2MeDebitConsent:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getMe2MeDebitConsent.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getCardStatement:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getCardStatement.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .saveCardName:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.saveCardName.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .blockCard:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.blockCard.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .unblockCard:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.unblockCard.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getProductDetails:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getProductDetails.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .setUserSetting:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.setUserSetting.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getUserSettings:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getUserSettings.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getPhoneInfo:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getPhoneInfo.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
        case .createMobileTransfer:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.createMobileTransfer.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }

        case .getSessionTimeout:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getSessionTimeout.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getAccountStatement:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getAccountStatement.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getLatestMobilePayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getLatestMobilePayments.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getMobileList:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getMobileList.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getAllLatestPayments:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getAllLatestPayments.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getOperationDetail:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getOperationDetail.rawValue)
            
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getNotifications:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getNotifications.rawValue)
            switch result {
            case .success(let url):
                return .success(url.absoluteURL)
            case .failure(let error):
                debugPrint(error)
                return .failure(.urlError)
            }
            
        case .getPrintFormForAccountStatement:
            let result = URLConstruct.setUrl(.https, .qa, RouterBaseUrlList.getPrintFormForAccountStatement.rawValue)
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
