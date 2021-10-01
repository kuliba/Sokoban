//
//  ExtensionNetworkHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.06.2021.
//

import Foundation

extension NetworkHelper {
    
    enum RequestType {
        
        /// Авторизация
        case loginDo
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
        
        case getBanks
        
        case getBankFullInfoList

        case anywayPaymentBegin

        case anywayPaymentMake

        case anywayPayment

        case prepareCard2Phone

        case getOwnerPhoneNumber

        case fastPaymentBanksList

        case makeCard2Card

        case getLatestPayments
        
        case getProductList
        
        case getPaymentSystemList
        
        case getCurrencyList
        
        case getExchangeCurrencyRates
        
        case getMobileSystem
    }
    
}
