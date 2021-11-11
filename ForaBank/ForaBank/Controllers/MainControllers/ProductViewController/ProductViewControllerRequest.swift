//
//  ProductViewControllerRequest.swift
//  ForaBank
//
//  Created by Дмитрий on 11.11.2021.
//

import Foundation


extension ProductViewController {
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
        
    }
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: fastPaymentContractFindList", model)
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

                completion(nil, model.errorMessage)
            }
        }
    }
    
    func accountHistory(){
        let body = ["id": product?.id
                     ] as [String : AnyObject]
        
        NetworkManager<GetAccountStatementDecodableModel>.addRequest(.getAccountStatement, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArrayAccount = lastPaymentsList
                    self.historyArray.removeAll()
                    self.historyArrayAccount.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            //At least one of your timestamps is nil.  You have to decide how to sort here.
                            return true
                        }
                    })
                    for i in self.historyArrayAccount{
                        
                        if let timeResult = (i.tranDate) {
                            print(timeResult)
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                            let localDate = dateFormatter.string(from: date)
                            print(localDate)
                        }
                    }
                    
                    
                    self.groupByCategoryAccount = Dictionary(grouping: self.historyArrayAccount) { $0.tranDate ?? 0 }
                    var unsortedCodeKeys = Array(self.groupByCategoryAccount.keys)
                    let sortedCodeKeys = unsortedCodeKeys.sort(by: >)
                        print(sortedCodeKeys)
//                    let dict = Dictionary(grouping: lastPaymentsList, by: { $0.tranDate ?? $0.date!/1000000 })
                    let dict = Dictionary(grouping: lastPaymentsList) { (element) -> String in
                        
                        guard let tranDate =  element.tranDate else {
                            return String(self.longIntToDateString(longInt: element.date!/1000)?.description ?? "0")
                        }
                        
                        return  String(self.longIntToDateString(longInt: tranDate/1000)?.description ?? "0")
                                            }
                    
                    self.sortedAccount = dict.sorted(by:{ ($0.value[0].tranDate ?? $0.value[0].date) ?? 0 > $1.value[0].tranDate ?? $1.value[0].date ?? 0})
                    
                    self.tableView?.stopSkeletonAnimation()
                    self.tableView?.hideSkeleton()
                    self.statusBarView.stopSkeletonAnimation()
                    self.statusBarView.hideSkeleton()
                    self.filterButton.hideSkeleton()
                    self.statusBarView.layer.cornerRadius = 8
                    self.view.hideSkeleton()

                    
                    for i in lastPaymentsList{
                        if i.operationType == "DEBIT"{
                            self.totalExpenses  += Double(i.amount ?? 0.0)
                        }
                    }
                }
//                    self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

            }
        }
    }
    
    
    func cardHistory(){
        
        let body = ["cardNumber": product?.number
                     ] as [String : AnyObject]
        
        NetworkManager<GetCardStatementDecodableModel>.addRequest(.getCardStatement, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArray = lastPaymentsList
                    self.historyArrayAccount.removeAll()
                    self.historyArray.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            //At least one of your timestamps is nil.  You have to decide how to sort here.
                            return true
                        }
                    })
                    for i in self.historyArray{
                        
                        if let timeResult = (i.tranDate) {
                            print(timeResult)
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                            let localDate = dateFormatter.string(from: date)
                            print(localDate)
                        }
                    }
                    
                    
                    self.groupByCategory = Dictionary(grouping: self.historyArray) { $0.tranDate ?? 0 }
                    var unsortedCodeKeys = Array(self.groupByCategory.keys)
                    let sortedCodeKeys: () = unsortedCodeKeys.sort(by: >)
                        print(sortedCodeKeys)

                    let dict = Dictionary(grouping: lastPaymentsList) { (element) -> String in
                        
                        guard let tranDate =  element.tranDate else {
                            return String(self.longIntToDateString(longInt: element.date!/1000)?.description ?? "0")
                        }
                        
                        return  String(self.longIntToDateString(longInt: tranDate/1000)?.description ?? "0")
                                            }
                    
                    self.sorted = dict.sorted(by:{ ($0.value[0].tranDate ?? $0.value[0].date) ?? 0 > $1.value[0].tranDate ?? $1.value[0].date ?? 0})
                 
                    
                    for i in lastPaymentsList{
                        if i.operationType == "DEBIT"{
                            self.totalExpenses  += Double(i.amount ?? 0.0)
                        }
                    }
                    
                    self.tableView?.stopSkeletonAnimation()
                    self.tableView?.hideSkeleton()
                  
                    self.view.hideSkeleton()
                    
                }
//                    self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

            }
        }
    }
    
}
