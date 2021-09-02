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
    
    /// Не используется
    case getCardList               = "/rest/getCardList"
    
    case keyExchange               = "/keyExchange"
    /// Надо в не авторизованную зону. Обновление по serial
    case getCountries              = "/rest/dict/getCountries"
    
    case anywayPaymentBegin        = "/rest/anywayPaymentBegin"
    
    case anywayPaymentMake         = "/rest/anywayPaymentMake"
    
    case anywayPayment             = "/rest/anywayPayment"
    
    case prepareCard2Phone         = "/rest/prepareCard2Phone"
    /// Надо в авторизованную зону. Сравнивать со словарем в REALM
    case getOwnerPhoneNumber       = "/rest/getOwnerPhoneNumber"
    /// Не используется
    case fastPaymentBanksList      = "/rest/fastPaymentBanksList"
    
    case makeCard2Card             = "/rest/makeCard2Card"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getLatestPayments         = "/rest/getLatestPayments"
    
    case getPrintForm              = "/rest/getPrintForm"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getLatestPhonePayments    = "/rest/getLatestPhonePayments"
    
    case createTransfer            = "/rest/transfer/createTransfer"
    
    case makeTransfer              = "/rest/transfer/makeTransfer"
    /// Надо в не авторизованную зону. Обновление по serial
    case getBanks                  = "/rest/dict/getBanks"
    /// Надо в не авторизованную зону. Обновление по serial
    case getPaymentSystemList      = "/rest/dict/getPaymentSystemList"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getProductList            = "/rest/getProductList"
    
    case getVerificationCode       = "/rest/transfer/getVerificationCode"
    /// Не используется
    case prepareExternal           = "/rest/prepareExternal"
    /// Вопрос для обсуждения. Нужно ли кэшировать
    case getExchangeCurrencyRates  = "/rest/getExchangeCurrencyRates"
    /// Не используется. И это уточнить
    case suggestBank               = "/rest/suggestBank"
    
    case suggestCompany            = "/rest/suggestCompany"
    /// Надо в не авторизованную зону. Обновление по serial
    case getCurrencyList           = "/rest/dict/getCurrencyList"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getProductTemplateList    = "/rest/getProductTemplateList"
    
    case deleteProductTemplate     = "/rest/deleteProductTemplate"
    /// Надо в авторизованную зону. Добавить поле в модель с номером карты и результатом проверки ( название банка )
    case checkCard                 = "/rest/transfer/checkCard"
    
    case logout                    = "/logout"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getPaymentCountries       = "/rest/getPaymentCountries"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getProductListByFilter    = "/rest/getProductListByFilter"
    /// Надо в не авторизованную зону. Обновление по serial
    case getAnywayOperatorsList    = "/rest/getAnywayOperatorsList"
    /// Надо в не авторизованную зону. Обновление по serial
    case getFullBankInfoList       = "/rest/dict/getFullBankInfoList"
    
    case createServiceTransfer     = "/rest/transfer/createServiceTransfer"
    
    case antiFraud                 = "/rest/transfer/antiFraud"
    
    case createMe2MePullTransfer   = "/rest/transfer/createMe2MePullTransfer"
    
    case createFastPaymentContract = "/rest/createFastPaymentContract"
    
    case updateFastPaymentContract = "/rest/updateFastPaymentContract"
    
    case fastPaymentContractFindList = "/rest/fastPaymentContractFindList"
    
    case createContactAddresslessTransfer = "/rest/transfer/createContactAddresslessTransfer"
    
    case createDirectTransfer             = "/rest/transfer/createDirectTransfer"
    /// Надо в авторизованную зону. Обновление при заходе на экран
    case getLatestServicePayments         = "/rest/getLatestServicePayments"
    
    case getClientConsentMe2MePull = "/rest/getClientConsentMe2MePull"
    
    case changeClientConsentMe2MePull = "/rest/changeClientConsentMe2MePull"
}
