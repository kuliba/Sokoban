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
        
        lazy var realm = try? Realm()
        
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
        let countriesBank = ["serial" : withIdBank, "type" : "", "bic":"", "serviceType":""]
        
        let operators = realm?.objects(GKHOperatorsModel.self)
        let withIdOperators = operators?.first?.serial ?? ""
        let countriesOperators = ["serial" : withIdOperators ]
        
        var downloadArray = [DownloadQueueProtocol]()
        var paramArray = [[String: String]]()
        
        downloadArray.append(CountriesListSaved())
        paramArray.append(countriesParam)
        
        downloadArray.append(GetPaymentSystemSaved())
        paramArray.append(paymentSystemParam)
        
        downloadArray.append(GetCurrencySaved())
        paramArray.append(currencyParam)

        downloadArray.append(BanksListSaved())
        paramArray.append(countriesBank)

        downloadArray.append(GetSessionTimeoutSaved())
        paramArray.append(["serial": ""])

        downloadArray.append(AddOperatorsList())
        paramArray.append(countriesOperators)
        
        let group = DispatchGroup()
        
        
        
        for (n, i) in downloadArray.enumerated() {
            group.enter()
            print(n, i)
            i.add(paramArray[n], [:]) {
                print(n, i)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
        
    }
}
