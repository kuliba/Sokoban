//
//  URLConstruct.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

struct URLConstruct {
    
    public typealias URLType = Result< URL, URLError >
    
    static func setUrl(_ scheme: URLSchemeType.URLScheme,
                       _ host: URLHost.URLHostType,
                       _ path: String) -> URLType {
        
        let temp = scheme.rawValue + "://" + host.rawValue + path
        
        let components = URLComponents(string: temp)
        
        guard components?.url != nil else {
            return .failure(.URLIsError)
        }
        return .success((components?.url)!)
    }
}

public enum URLError: Error {
    case URLIsError
}

