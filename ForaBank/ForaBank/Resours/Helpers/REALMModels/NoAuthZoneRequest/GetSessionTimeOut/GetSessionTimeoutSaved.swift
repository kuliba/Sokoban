//
//  GetSessionTimeoutSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.09.2021.
//

import Foundation
import RealmSwift

struct GetSessionTimeoutSaved: DownloadQueueProtocol {
    
    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping (DownloadQueue.Result) -> Void) {
        
        NetworkManager<GetSessionTimeoutDecodableModel>.addRequest(.getSessionTimeout, param, body) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
                completion(.failed(nil))
            } else {
                guard let statusCode = model?.statusCode else {
                    completion(.failed(nil))
                    return
                    
                }
                if statusCode == 0 {
                    
                    //FIXME: in fact, we never use the data received from the server
                    let sessionTimeOutParameters = returnRealmModel()
                    sessionTimeOutParameters.maxTimeOut = StaticDefaultTimeOut.staticDefaultTimeOut
                    sessionTimeOutParameters.mustCheckTimeOut = true
                    
                    /// Сохраняем в REALM
                    do {
                        let realm = try? Realm()
                        let b = realm?.objects(GetSessionTimeout.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(sessionTimeOutParameters)
                        try realm?.commitWrite()
                        completion(.passed)
                    } catch {
                        completion(.failed(error))
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

