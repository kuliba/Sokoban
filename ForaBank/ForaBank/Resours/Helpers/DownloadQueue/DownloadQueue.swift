//
//  DownloadQueue.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation
import RealmSwift

struct DownloadQueue {
    
    var downloadArray = [DownloadQueueProtocol]()
    var paramArray = [[String: String]]()
    
    /// Функция загрузки
    mutating func download(_ completion: @escaping () -> ()) {
        setDownloadQueue()
        
        for (n, i) in self.downloadArray.enumerated() {
            let semaphore = DispatchSemaphore(value: 0)
                i.add(paramArray[n], [:]) {
                    semaphore.signal()
                }
            semaphore.wait()
        }
    }
    
    private mutating func setDownloadQueue() {
        
        lazy var realm = try? Realm()
        
        let countries = realm?.objects(GetCountries.self)
        let withIdCountries = countries?.first?.serial ?? ""
        let countriesParam = ["serial" : withIdCountries ]
        
//        let paymentSystem = realm?.objects(GetPaymentSystemList.self)
//        let withIdPaymentSystem = paymentSystem?.first?.serial ?? ""
//        let paymentSystemParam = ["serial" : withIdPaymentSystem ]
        
        let currency = realm?.objects(GetCurrency.self)
        let withIdCurrency = currency?.first?.serial ?? ""
        let currencyParam = ["serial" : withIdCurrency ]
        
        let bank = realm?.objects(GetBankList.self)
        let withIdBank = bank?.first?.serial ?? ""
        let countriesBank = ["serial" : withIdBank, "type" : "", "bic":"", "serviceType":""]
        
        let operators = realm?.objects(GKHOperatorsModel.self)
        let withIdOperators = operators?.first?.serial ?? ""
        let countriesOperators = ["serial" : withIdOperators ]
        
        downloadArray.append(CountriesListSaved())
        paramArray.append(countriesParam)
        
        //        downloadArray.append(GetPaymentSystemSaved())
        //        paramArray.append(paymentSystemParam)
        
        downloadArray.append(GetCurrencySaved())
        paramArray.append(currencyParam)
        
        downloadArray.append(BanksListSaved())
        paramArray.append(countriesBank)
        downloadArray.append(AddOperatorsList())
        paramArray.append(countriesOperators)
        
        downloadArray.append(GetSessionTimeoutSaved())
        paramArray.append(["serial": ""])
        
    }
}
