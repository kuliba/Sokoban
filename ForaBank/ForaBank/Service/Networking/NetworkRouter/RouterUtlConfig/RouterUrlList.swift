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
        }
    }
}
