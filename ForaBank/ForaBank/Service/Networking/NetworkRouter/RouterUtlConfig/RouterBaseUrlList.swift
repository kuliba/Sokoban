//
//  RouterBaseUrlList.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum RouterBaseUrlList: String {
    
    // MARK: Отправка запроса на авторизацию
    
    /// Авторизация
    /// "login.do"
    case login                     = "/login.do"
    
    /// Авторизация приложения
    /// "setDeviceSettting"
    case setDeviceSettting         = "/registration/setDeviceSettings"
    
    /// Получение токена при запуске приложения
    /// "/csrf/"
    case csrf                      = "/csrf"
    
    /// Получение токена при запуске приложения
    /// "/registration/checkClient"
    case checkClient               = "/registration/checkClient"
    
    case verifyCode                = "/registration/verifyCode"
    
    case doRegistration            = "/registration/doRegistration"
    
    case getCode                   = "/registration/getCode"
    
    case installPushDevice         = "/push_device/installPushDevice"
    
    case registerPushDeviceForUser = "/push_device_user/registerPushDeviceForUser"
    
    case uninstallPushDevice       = "/push_device/uninstallPushDevice"
    
    case getCardList               = "/rest/getCardList"
    
    case keyExchange               = "/keyExchange"
    
    case getCountries              = "/rest/dict/getCountries"
    
    case anywayPaymentBegin        = "/rest/anywayPaymentBegin"
    
    case anywayPaymentMake         = "/rest/anywayPaymentMake"
    
    case anywayPayment             = "/rest/anywayPayment"
    
    case prepareCard2Phone         = "/rest/prepareCard2Phone"
    
    case getOwnerPhoneNumber       = "/rest/getOwnerPhoneNumber"
    
    case fastPaymentBanksList      = "/rest/fastPaymentBanksList"
    
    case makeCard2Card             = "/rest/makeCard2Card"
    
    case getLatestPayments         = "/rest/getLatestPayments"
    
    case getPrintForm              = "/rest/getPrintForm"
    
    case getLatestPhonePayments    = "/rest/getLatestPhonePayments"
    
    case createTransfer            = "/rest/transfer/createTransfer"
    
    case makeTransfer              = "/rest/transfer/makeTransfer"
    
    case getBanks                  = "/rest/dict/getBanks"
    
    case getPaymentSystemList      = "/rest/dict/getPaymentSystemList"
    
    case getProductList            = "/rest/getProductList"
    
    case getVerificationCode       = "/rest/transfer/getVerificationCode"
    
    case prepareExternal           = "/rest/prepareExternal"
    
    case getExchangeCurrencyRates  = "/rest/getExchangeCurrencyRates"
    
    case suggestBank               = "/rest/suggestBank"
    
    case suggestCompany            = "/rest/suggestCompany"
    
    case getCurrencyList           = "/rest/dict/getCurrencyList"
    
    case getProductTemplateList    = "/rest/getProductTemplateList"
    
    case deleteProductTemplate     = "/rest/deleteProductTemplate"
    
    case checkCard                 = "/rest/transfer/checkCard"
    
    case logout                    = "/logout"
    
    case getPaymentCountries       = "/rest/getPaymentCountries"
    
    case getProductListByFilter    = "/rest/getProductListByFilter"
}
