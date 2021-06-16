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
    case login = "/login.do"
    
    /// Авторизация приложения
    /// "setDeviceSettting"
    case setDeviceSettting = "/registration/setDeviceSettings"
    
    /// Получение токена при запуске приложения
    /// "/csrf/"
    case csrf = "/csrf"
    
    /// Получение токена при запуске приложения
    /// "/registration/checkClient"
    case checkClient = "/registration/checkClient"
    
    case verifyCode = "/registration/verifyCode"
    
    case doRegistration = "/registration/doRegistration"
    
    case getCode = "/registration/getCode"
    
    case installPushDevice = "/push_device/installPushDevice"
    
    case registerPushDeviceForUser = "/push_device_user/registerPushDeviceForUser"
    
    case uninstallPushDevice = "/push_device/uninstallPushDevice"
    
    case getCardList = "/rest/getCardList"
    
    case keyExchange = "/keyExchange"
    
    case getCountries = "/rest/dict/getCounties"
    
    case anywayPaymentBegin = "/rest/anywayPaymentBegin"
    
    case anywayPaymentMake = "/rest/anywayPaymentMake"
    
    case anywayPayment = "/rest/anywayPayment"
}
