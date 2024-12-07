//
//  URLConstruct.swift
//  Vortex
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

enum URLConstruct {
    
    public typealias URLType = Result< URL, URLError >
    
    static func setUrl(_ scheme: URLSchemeType.URLScheme,
                       _ host: URLHost.URLHostType,
                       _ path: String) -> URLType {
        
#if MOCK
        let temp = "http://" + host.getHostValue() + path
#else
        let temp = scheme.rawValue + "://" + host.getHostValue() + path
#endif
        
        let components = URLComponents(string: temp)
        
        guard let url = components?.url else {
            return .failure(.URLIsError)
        }
        
        return .success(url)
    }
}

public enum URLError: Error {
    case URLIsError
}
