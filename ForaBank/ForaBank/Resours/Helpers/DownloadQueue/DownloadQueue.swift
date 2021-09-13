//
//  DownloadQueue.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation
import RealmSwift

struct DownloadQueue {
    
    /// Функция загрузки
    static func download(_ completion: @escaping () -> ()) {
        
        let realm = try? Realm()
        
        let countries = realm?.objects(GetCountries.self)
        let withIdCountries = countries?.first?.serial ?? ""
        let countriesParam = ["serial" : withIdCountries ]
        
        let paymentSystem = realm?.objects(GetPaymentSystemList.self)
        let withIdPaymentSystem = paymentSystem?.first?.serial ?? ""
        let paymentSystemParam = ["serial" : withIdPaymentSystem ]
        
        let currency = realm?.objects(GetCurrency.self)
        let withIdCurrency = currency?.first?.serial ?? ""
        let currencyParam = ["serial" : withIdCurrency ]
        
        let bank = realm?.objects(GetBankList.self)
        let withIdBank = bank?.first?.serial ?? ""
        let countriesBank = ["serial" : withIdBank ]
        
//        let operators = realm?.objects(GKHOperatorsModel.self)
//        let withIdOperators = operators?.first?.serial ?? ""
//        let countriesOperators = ["serial" : withIdOperators ]
        
        var downloadArray = [DownloadQueueProtocol]()
        
        if withIdCountries == "" {
            downloadArray.append(CountriesListSaved())
        }
        
        if withIdPaymentSystem == "" {
            downloadArray.append(GetPaymentSystemSaved())
        }
        
        if withIdCurrency == "" {
            downloadArray.append(GetCurrencySaved())
        }
        
        if withIdBank == "" {
            downloadArray.append(BanksListSaved())
        }
        
        downloadArray.append(AddOperatorsList())
        
        for i in downloadArray {
            let semaphore = DispatchSemaphore(value: 0)
            i.add(countriesParam, [:]) {
                semaphore.signal()
            }
            semaphore.wait()
        }
        completion()
    }
}
