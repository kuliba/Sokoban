//
//  RouterManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum RouterManager {
    case login
    case setDeviceSetting
    case csrf
    case checkCkient
    case verifyCode
    case doRegistration
    case getCode
    case installPushDevice
    case registerPushDeviceForUser
    case uninstallPushDevice
    case getCardList
    case keyExchange
    case getCountries
}

extension RouterManager {
    func request() -> URLRequest? {
        let resultUrl: URL?
        switch self {
        case .login:
            let baseUrl = RouterUrlList.login.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        
        case .setDeviceSetting:
            let baseUrl = RouterUrlList.setDeviceSetting.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        
        case .csrf:
            let baseUrl = RouterUrlList.csrf.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.get.rawValue
            return request
            
        case .checkCkient:
            let baseUrl = RouterUrlList.chackClient.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .verifyCode:
            let baseUrl = RouterUrlList.verifyCode.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .doRegistration:
            let baseUrl = RouterUrlList.doRegistration.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCode:
            let baseUrl = RouterUrlList.getCode.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        case .installPushDevice:
            let baseUrl = RouterUrlList.installPushDevice.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .registerPushDeviceForUser:
            let baseUrl = RouterUrlList.registerPushDeviceForUser.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .uninstallPushDevice:
            let baseUrl = RouterUrlList.uninstallPushDevice.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCardList:
            let baseUrl = RouterUrlList.getCardList.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .keyExchange:
            let baseUrl = RouterUrlList.keyExchange.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
            
        case .getCountries:
            let baseUrl = RouterUrlList.getCountries.returnUrl()
            switch baseUrl {
            case .success(let url):
                resultUrl = url.absoluteURL
            case .failure(let error):
                resultUrl = nil
                debugPrint(error)
            }
            
            guard resultUrl != nil else { return nil}
            var request = URLRequest(url: resultUrl!)
            request.httpMethod = RequestMethod.post.rawValue
            return request
        }
    }
}

