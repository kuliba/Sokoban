//
//  DownloadQueueSerialsStorage.swift
//  ForaBank
//
//  Created by Max Gribov on 07.12.2021.
//

import Foundation

class DownloadQueueSerialsStorage {
    
    let defaults = UserDefaults.standard
    
    func serial(for kind: Kind) -> String {
        
        return defaults.string(forKey: kind.key) ?? ""
    }
    
    func store(serial: String, of kind: Kind) {
        
        defaults.set(serial, forKey: kind.key)
        defaults.synchronize()
    }
}

extension DownloadQueueSerialsStorage {
    
    enum Kind: String {
        
        case sessionTimeout
        case countryList
        case paymentSystemList
        case currencyList
        case bankList
        case operatorList
        
        var key: String { "DownloadQueueStorage_\(rawValue)_Key"}
    }
}
