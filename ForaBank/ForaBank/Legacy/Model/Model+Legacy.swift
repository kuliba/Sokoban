//
//  Model+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 31.05.2022.
//

import Foundation

extension Model {
    
    var cookies: [HTTPCookie]? {
        
        guard let actualServerAgent = serverAgent as? ServerAgent else {
            return nil
        }
        
        return actualServerAgent.cookies
    }
}
