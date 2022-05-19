//
//  ProductViewControllerRequest.swift
//  ForaBank
//
//  Created by Дмитрий on 11.11.2021.
//

import Foundation
import UIKit


extension ProductViewController {
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "true", "isLoan": "true"]
        
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
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
    }
    
    func accountHistory() {
        
        let body = ["id": product?.id ] as [String : AnyObject]
        
        NetworkManager<GetAccountStatementDecodableModel>.addRequest(.getAccountStatement, [:], body) { model, error in
            if error != nil {
                self.emptySpending.isHidden = false
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    self.stopSkeleton()
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArrayAccount = lastPaymentsList
                    self.historyArray.removeAll()
                    self.historyArrayAccount.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            return true
                        }
                    })
                    for i in self.historyArrayAccount{
                        
                        if let timeResult = (i.tranDate) {
                            _ = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none
                            dateFormatter.dateStyle = DateFormatter.Style.medium
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                        }
                    }
                    
                    self.groupByCategoryAccount = Dictionary(grouping: self.historyArrayAccount) { $0.tranDate ?? 0 }
                    var unsortedCodeKeys = Array(self.groupByCategoryAccount.keys)
                    let _: () = unsortedCodeKeys.sort(by: >)
                    let dict = Dictionary(grouping: lastPaymentsList) { (element) -> String in
                        
                        guard let tranDate =  element.tranDate else {
                            return String(self.longIntToDateString(longInt: element.date!/1000)?.description ?? "0")
                        }
                        
                        return  String(self.longIntToDateString(longInt: tranDate/1000)?.description ?? "0")
                    }
                    
                    self.sortedAccount = dict.sorted(by:{ ($0.value[0].tranDate ?? $0.value[0].date) ?? 0 > $1.value[0].tranDate ?? $1.value[0].date ?? 0})
                    
                    if dict.count > 0 {
                        
                        self.emptySpending.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        
                    } else {
                        self.tableView.isHidden = true
                        self.statusBarView.isHidden = true
                        self.emptySpending.isHidden = false
                    }
                    
                    for i in lastPaymentsList{
                        if i.operationType == "DEBIT"{
                            self.totalExpenses  += Double(i.amount ?? 0.0)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    
                    self.emptySpending.isHidden = false
                }
            }
        }
    }
    
    
    func cardHistory(){
        
        let body = ["id": product?.id] as [String : AnyObject]
        
        NetworkManager<GetCardStatementDecodableModel>.addRequest(.getCardStatement, [:], body) { model, error in
            if error != nil {
                self.emptySpending.isHidden = false
                
            }
            guard let model = model else { return }

            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    
                    self.stopSkeleton()
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArray = lastPaymentsList
                    self.historyArrayAccount.removeAll()
                    self.historyArrayDeposit.removeAll()
                    self.historyArray.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            return true
                        }
                    })
                    for i in self.historyArray{
                        
                        if let timeResult = (i.tranDate) {
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                            _ = dateFormatter.string(from: date)
                        }
                    }
                    
                    
                    self.groupByCategory = Dictionary(grouping: self.historyArray) { $0.tranDate ?? 0 }
                    var unsortedCodeKeys = Array(self.groupByCategory.keys)
                    let _: () = unsortedCodeKeys.sort(by: >)
                    
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
                    
                    if dict.count > 0 {
                        
                        self.emptySpending.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        

                    } else {
                        
                        self.tableView.isHidden = true
                        self.statusBarView.isHidden = true
                        self.emptySpending.isHidden = false
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.emptySpending.isHidden = false
                }
                
            }
        }
    }
    
    func loadDeposit(){
        
        let body = ["id": product?.id
        ] as [String : AnyObject]
        
        NetworkManager<GetDepositStatementDecodableModel>.addRequest(.getDepositStatement, [:], body) { model, error in
            if error != nil {
                self.emptySpending.isHidden = false
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    self.stopSkeleton()
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArrayDeposit = lastPaymentsList
                    self.historyArray.removeAll()
                    self.historyArrayDeposit.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
            
                            return timestamp1 > timestamp2
                        } else {
            
                            return true
                        }
                    })
                    for i in self.historyArrayDeposit{
                        
                        if let timeResult = (i.tranDate) {
                            
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none
                            dateFormatter.dateStyle = DateFormatter.Style.medium
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                            _ = dateFormatter.string(from: date)
                        }
                    }
                
                    self.groupByCategoryDeposit = Dictionary(grouping: self.historyArrayDeposit) { $0.tranDate ?? 0 }
                    
                    var unsortedCodeKeys = Array(self.groupByCategoryAccount.keys)
                    let _: () = unsortedCodeKeys.sort(by: >)
                    
                    let dict = Dictionary(grouping: lastPaymentsList) { (element) -> String in
                        
                        guard let tranDate =  element.tranDate else {
                            return String(self.longIntToDateString(longInt: element.date!/1000)?.description ?? "0")
                        }
                        
                        return  String(self.longIntToDateString(longInt: tranDate/1000)?.description ?? "0")
                    }
                    
                    self.sortedDeposit = dict.sorted(by:{ ($0.value[0].tranDate ?? $0.value[0].date) ?? 0 > $1.value[0].tranDate ?? $1.value[0].date ?? 0})
                    
                    if dict.count > 0 {
                        
                        self.emptySpending.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        self.tableView.hideSkeleton()

                    } else {
                        
                        self.tableView.isHidden = true
                        self.statusBarView.isHidden = true
                        self.emptySpending.isHidden = false
                    }
                    
                    for i in lastPaymentsList{
                        if i.operationType == "DEBIT"{
                            self.totalExpenses  += Double(i.amount ?? 0.0)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.emptySpending.isHidden = false
                }
            }
        }
    }
    
    func stopSkeleton() {
        
        self.tableView.stopSkeletonAnimation()
        self.tableView.hideSkeleton()
        self.view.stopSkeletonAnimation()
        self.view.hideSkeleton()
        self.statusBarView.stopSkeletonAnimation()
        self.statusBarView.hideSkeleton()
    }
    
}
