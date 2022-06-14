//
//  PaymentSystemList+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 14.06.2022.
//

import Foundation

extension PaymentSystemData {
    
    func getPaymentSystem() -> PaymentSystemList {
        
        func mapPurefList() -> [[String : [PurefList]]]? {
            
            var result: [[String : [PurefList]]] = []
            
            if let purefList = purefList {
                
                purefList.forEach { dict in
                    
                    dict.forEach { (key, value) in
                        
                        let dictRes = [key : value.map { $0.getPurefList() }]
                        
                        result.append(dictRes)
                    }
                }
                return result
                
            } else {
                
                return nil
            }
        }
        
        return PaymentSystemList(code: code, name: name, md5Hash: md5hash, svgImage: svgImage.description, purefList: mapPurefList())
    }
    
}

extension PaymentSystemData.PurefData {

    func getPurefList() -> PurefList {
        
        PurefList(puref: puref, type: type)
    }
}
