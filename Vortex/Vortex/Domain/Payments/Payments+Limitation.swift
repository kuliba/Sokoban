//
//  Payments+Limitation.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 27.12.2022.
//

import Foundation

extension Payments {
    
    struct Limitation {
        
        let limit: Int
        
        init(limit: Int) {
            
            self.limit = limit
        }
    }
}
