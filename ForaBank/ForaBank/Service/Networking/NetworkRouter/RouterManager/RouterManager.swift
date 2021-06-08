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
            let baseUrl = RouterUrlList.setDeviceSettting.returnUrl()
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

