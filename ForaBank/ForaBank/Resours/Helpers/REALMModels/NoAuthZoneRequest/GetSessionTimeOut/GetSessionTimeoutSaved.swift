//
//  GetSessionTimeoutSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.09.2021.
//

import Foundation
import RealmSwift

struct GetSessionTimeoutSaved: DownloadQueueProtocol {
    
    func add(_ param: [String : String], _ body: [String : AnyObject], completion: @escaping () -> ()) {
        
        NetworkManager<GetSessionTimeoutDecodableModel>.addRequest(.getSessionTimeout, param, body) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
              //      guard let model = model else { return }
             //       guard let m = model.data else { return }
                    
                    
                    
                    let sessionTimeOutParameters = returnRealmModel()
                    sessionTimeOutParameters.maxTimeOut = StaticDefaultTimeOut.staticDefaultTimeOut
                    sessionTimeOutParameters.mustCheckTimeOut = true
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let b = realm?.objects(GetSessionTimeout.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(sessionTimeOutParameters)
                        try realm?.commitWrite()
                        print("REALM", realm?.configuration.fileURL?.absoluteString ?? "")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func returnRealmModel() -> GetSessionTimeout {
        let realm = try? Realm()
        guard let timeObject = realm?.objects(GetSessionTimeout.self).first else {return GetSessionTimeout()}
        let lastActionTimestamp = timeObject.lastActionTimestamp
        let maxTimeOut = timeObject.maxTimeOut
        let mustCheckTimeOut = timeObject.mustCheckTimeOut
        
        // Сохраняем текущее время
        let updatingTimeObject = GetSessionTimeout()
        
        updatingTimeObject.lastActionTimestamp = lastActionTimestamp
        updatingTimeObject.renewSessionTimeStamp = Date().localDate()
        updatingTimeObject.maxTimeOut = maxTimeOut
        updatingTimeObject.mustCheckTimeOut = mustCheckTimeOut
        
        return updatingTimeObject
        
    }
}

