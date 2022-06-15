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
    
    var dictionaryBankListLegacy: [BanksList]? {

        return bankList.value.map{ $0.getBanksList() }
   }

    var productsLegacy: [UserAllCardsModel] {

       products.value.values.flatMap({ $0 }).map{ $0.userAllProducts() }
    }

}
