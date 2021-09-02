//
//  RouterBaseUrlList.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum RouterBaseUrlList: String {
    
    // MARK: - Отправка запроса на авторизацию
    
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
    
    case keyExchange               = "/keyExchange"
    
    case anywayPaymentBegin        = "/rest/anywayPaymentBegin"
    
    case anywayPaymentMake         = "/rest/anywayPaymentMake"
    
    case anywayPayment             = "/rest/anywayPayment"
    
    case prepareCard2Phone         = "/rest/prepareCard2Phone"
    /// Надо в авторизованную зону. Сравнивать со словарем в REALM
    case getOwnerPhoneNumber       = "/rest/getOwnerPhoneNumber"
    
    case makeCard2Card             = "/rest/makeCard2Card"
    
    
    case getPrintForm              = "/rest/getPrintForm"
    
    case createTransfer            = "/rest/transfer/createTransfer"
    
    case makeTransfer              = "/rest/transfer/makeTransfer"
    
    case getVerificationCode       = "/rest/transfer/getVerificationCode"
    
    case suggestCompany            = "/rest/suggestCompany"
    
    case deleteProductTemplate     = "/rest/deleteProductTemplate"
    
    case logout                    = "/logout"
    
    case createServiceTransfer     = "/rest/transfer/createServiceTransfer"
    
    case antiFraud                 = "/rest/transfer/antiFraud"
    
    case createMe2MePullTransfer   = "/rest/transfer/createMe2MePullTransfer"
    
    case createFastPaymentContract = "/rest/createFastPaymentContract"
    
    case updateFastPaymentContract = "/rest/updateFastPaymentContract"
    
    case fastPaymentContractFindList = "/rest/fastPaymentContractFindList"
    
    case createContactAddresslessTransfer = "/rest/transfer/createContactAddresslessTransfer"
    
    case createDirectTransfer      = "/rest/transfer/createDirectTransfer"
    
    case getClientConsentMe2MePull = "/rest/getClientConsentMe2MePull"
    
    case changeClientConsentMe2MePull = "/rest/changeClientConsentMe2MePull"
    
    // MARK: - В не авторизованную зону.
    ///Обновление по serial
    #if DEBUG
    case getAnywayOperatorsList    = "/getAnywayOperatorsList"
    case getFullBankInfoList       = "/dict/getFullBankInfoList"
    case getCurrencyList           = "/dict/getCurrencyList"
    case getBanks                  = "/dict/getBanks"
    case getPaymentSystemList      = "/dict/getPaymentSystemList"
    case getCountries              = "/dict/getCountries"

    #elseif RELEASE
    case getAnywayOperatorsList    = "/rest/getAnywayOperatorsList"
    case getFullBankInfoList       = "/rest/dict/getFullBankInfoList"
    case getCurrencyList           = "/rest/dict/getCurrencyList"
    case getBanks                  = "/rest/dict/getBanks"
    case getPaymentSystemList      = "/rest/dict/getPaymentSystemList"
    case getCountries              = "/rest/dict/getCountries"
    #endif
    
    // MARK: - Надо в авторизованную зону.
    /// Обновление при заходе на экран
    case getLatestServicePayments  = "/rest/getLatestServicePayments"
    
    case getPaymentCountries       = "/rest/getPaymentCountries"
    
    case getProductListByFilter    = "/rest/getProductListByFilter"
    
    case getProductTemplateList    = "/rest/getProductTemplateList"
    
    case getProductList            = "/rest/getProductList"
    
    case getLatestPhonePayments    = "/rest/getLatestPhonePayments"
    
    case getLatestPayments         = "/rest/getLatestPayments"
    /// Добавить поле в модель с номером карты и результатом проверки ( название банка )
    case checkCard                 = "/rest/transfer/checkCard"
    /// Вопрос для обсуждения. Нужно ли кэшировать
    case getExchangeCurrencyRates  = "/rest/getExchangeCurrencyRates"
    
    
    // MARK: - Не используется
    
    case prepareExternal           = "/rest/prepareExternal"
    
    case getCardList               = "/rest/getCardList"
    
    case fastPaymentBanksList      = "/rest/fastPaymentBanksList"
    /// Не используется. И это уточнить
    case suggestBank               = "/rest/suggestBank"
}
