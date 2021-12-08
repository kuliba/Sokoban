//
//  DownloadQueueSerialsStorage.swift
//  ForaBank
//
//  Created by Max Gribov on 07.12.2021.
//

import Foundation

class DownloadQueueSerialsStorage {
    
    let defaults = UserDefaults.standard
    
    func serial(for kind: DownloadQueue.Kind) -> String {
        
        return defaults.string(forKey: kind.key) ?? ""
    }
    
    func store(serial: String, of kind: DownloadQueue.Kind) {
        
        defaults.set(serial, forKey: kind.key)
        defaults.synchronize()
    }
}
