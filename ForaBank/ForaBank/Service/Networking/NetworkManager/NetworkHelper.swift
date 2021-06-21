//
//  NetworkHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.06.2021.
//

import Foundation

struct NetworkHelper<T: NetworkModelProtocol> {
    
    static func request(_ parametrs: [String]? = nil,
                        _ complischen: @escaping () -> Void) {
        
        if parametrs != nil {
            
            
        } else {
        }
        
//        NetworkManager<T>.addRequest(T, parametrs, <#T##requestBody: [String : AnyObject]##[String : AnyObject]#>) { model, error in
//            <#code#>
//        }
        
    }
    
}
