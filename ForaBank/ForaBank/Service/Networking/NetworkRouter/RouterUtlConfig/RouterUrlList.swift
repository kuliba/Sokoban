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
        }
    }
}
