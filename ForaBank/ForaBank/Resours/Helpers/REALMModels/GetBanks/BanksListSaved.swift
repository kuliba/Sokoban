//
//  BanksListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

struct BanksListSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetBanksDecodableModel>.addRequest(.getBanks, param, body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let banks = model.data else { return }
                    
                    let banksList = GetBankList()
                    banksList.serial = banks.serial
                    
                    banks.banksList?.forEach{ bank in
                        let a = BankList()
                        a.md5hash = bank.md5Hash
                        a.memberId = bank.memberID
                        a.memberName = bank.memberName
                        a.memberNameRus = bank.memberNameRus
                        a.svgImage = bank.svgImage
                        bank.paymentSystemCodeList?.forEach{ list in
                            a.paymentSystemCodeList.append(list)
                        }
                        banksList.banksList.append(a)
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let banks = realm?.objects(GetBankList.self)
                        realm?.beginWrite()
                        realm?.delete(banks!)
                        realm?.add(banksList)
                        try realm?.commitWrite()
                        print(realm?.configuration.fileURL?.absoluteString ?? "")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
