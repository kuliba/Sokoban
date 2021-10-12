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
    
    case createMe2MePullCreditTransfer   = "/rest/transfer/createMe2MePullCreditTransfer"
    
    case createFastPaymentContract = "/rest/createFastPaymentContract"
    
    case updateFastPaymentContract = "/rest/updateFastPaymentContract"
    
    case fastPaymentContractFindList = "/rest/fastPaymentContractFindList"
    
    case createContactAddresslessTransfer = "/rest/transfer/createContactAddresslessTransfer"
    
    case createDirectTransfer      = "/rest/transfer/createDirectTransfer"
    
    case getClientConsentMe2MePull = "/rest/getClientConsentMe2MePull"
    
    case changeClientConsentMe2MePull = "/rest/changeClientConsentMe2MePull"
    
    case createSFPTransfer         = "/rest/transfer/createSFPTransfer"
    
    case createIsOneTimeConsentMe2MePull = "/rest/createIsOneTimeConsentMe2MePull"
    
    case createPermanentConsentMe2MePull = "/rest/createPermanentConsentMe2MePull"
    
    case isLogin                   = "/rest/isLogin"
    
    case createMe2MePullDebitTransfer    = "/rest/transfer/createMe2MePullDebitTransfer"
    
    case getMe2MeDebitConsent       =  "/rest/getMe2MeDebitConsent"
    
    
    
    case getCardStatement           = "/rest/getCardStatement"
    
    case saveCardName               = "/rest/saveCardName"
    
    case blockCard                  = "/rest/blockCard"
    
    case unblockCard                = "/rest/unblockCard"
    
    case getProductDetails          = "/rest/getProductDetails"
    
    case setUserSetting             = "/rest/setUserSetting"
    
    case getUserSettings            = "/rest/getUserSettings"
    
    case getPhoneInfo               = "/rest/getPhoneInfo"
    
    case createMobileTransfer       = "/rest/transfer/createMobileTransfer"
    
    case getSessionTimeout          = "/getSessionTimeout"
    
    case getAccountStatement        = "/rest/getAccountStatement"
    
    case getLatestMobilePayments    = "/rest/getLatestMobilePayments"
    
    case getMobileList             = "/dict/getMobileList"
    
    // MARK: - В не авторизованную зону.
    ///Обновление по serial
        
    case getAnywayOperatorsList    = "/dict/getAnywayOperatorsList"
    case getFullBankInfoList       = "/dict/getFullBankInfoList"
    case getCurrencyList           = "/dict/getCurrencyList"
    // Не делать
    case getBanks                  = "/dict/getBanks"
    //
    case getPaymentSystemList      = "/dict/getPaymentSystemList"
    case getCountries              = "/dict/getCountries"
    
    // MARK: - Надо в авторизованную зону.
    /// Обновление при заходе на экран

    case getLatestServicePayments  = "/rest/getLatestServicePayments"

    case getPaymentCountries       = "/rest/getPaymentCountries"
    // В процессе
    case getProductListByFilter    = "/rest/getProductListByFilter"

    case getProductTemplateList    = "/rest/getProductTemplateList"

    case getLatestPhonePayments    = "/rest/getLatestPhonePayments"
    
    case getLatestPayments         = "/rest/getLatestPayments"
    
    case getAllLatestPayments      = "/rest/getAllLatestPayments"
    
    /// Добавить поле в модель с номером карты и результатом проверки ( название банка )
    case checkCard                 = "/rest/transfer/checkCard"
    /// Вопрос для обсуждения. Нужно ли кэшировать
    case getExchangeCurrencyRates  = "/rest/getExchangeCurrencyRates"
    
    
    // MARK: - Не используется
    
    case getProductList            = "/rest/getProductList"
    
    case prepareExternal           = "/rest/prepareExternal"
    
    case getCardList               = "/rest/getCardList"
    
    case fastPaymentBanksList      = "/rest/fastPaymentBanksList"
    /// Не используется. И это уточнить
    case suggestBank               = "/rest/suggestBank"
}
