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
        }
    }
}

