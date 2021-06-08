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
    
}
