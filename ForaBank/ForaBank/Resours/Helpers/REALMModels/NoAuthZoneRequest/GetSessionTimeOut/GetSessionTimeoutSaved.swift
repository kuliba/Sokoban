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
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    let currency = GetSessionTimeout()
                    currency.timeDistance = m
                    
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let time = dateFormatter.string(from: date)
                    // Сохраняем текущее время
                    currency.currentTimeStamp = time
                    currency.reNewSessionTimeStamp = time
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let b = realm?.objects(GetSessionTimeout.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(currency)
                        try realm?.commitWrite()
                        print("REALM", realm?.configuration.fileURL?.absoluteString ?? "")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

