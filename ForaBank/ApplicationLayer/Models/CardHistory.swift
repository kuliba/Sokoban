//
//  CardHistory.swift
//  ForaBank
//
//  Created by Дмитрий on 18/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

class HistoryCard {
   let  accountID: Int?
    let amount: Int?
    let comment: String?
    let operationType: String?  
    
    init(  amount: Int? =  nil, comment: String? = nil , operationType: String? = nil, accountID: Int? = nil ) {
        self.amount = amount
        self.comment = comment
        self.operationType = operationType
        self.accountID = accountID

    }
}



