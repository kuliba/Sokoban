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
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList, param, body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let banks = model.data else { return }
                    
                    let banksList = GetBankList()
                    banksList.serial = banks.serial
                    
                    banks.bankFullInfoList?.forEach{ bank in
                        let a = BankList()
                        
                        a.memberId = bank.memberID
                        a.name = bank.name
                        a.fullName = bank.fullName
                        a.engName = bank.engName
                        a.rusName = bank.rusName
                        a.svgImage = bank.svgImage
                        a.bic = bank.bic
                        a.fiasId = bank.fiasID
                        a.address = bank.address
                        a.latitude = bank.latitude
                        
                        a.longitude = bank.longitude
                        a.inn = bank.inn
                        a.kpp = bank.kpp
                        a.registrationNumber = bank.registrationNumber
                        a.bankType = bank.bankType
                        a.bankTypeCode = bank.bankTypeCode
                        a.bankServiceType = bank.bankServiceType
                        a.bankServiceTypeCode = bank.bankServiceTypeCode
                        
                        bank.accountList?.forEach{ list in
                            
                            let b = BankAccauntList()
                            
                            b.account = list.account
                            b.regulationAccountType = list.regulationAccountType
                            b.ck = list.ck
                            b.dateIn = list.dateIn
                            b.dateOut = list.dateOut
                            b.status = list.status
                            b.CBRBIC = list.cbrbic
                            a.accountList.append(b)
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
