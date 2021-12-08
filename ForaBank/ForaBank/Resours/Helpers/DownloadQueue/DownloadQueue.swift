//
//  DownloadQueue.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation
import RealmSwift

final class DownloadQueue {
    
    private let serialsStorage = DownloadQueueSerialsStorage()
    private let queue = DispatchQueue(label: "ru.forabank.sense.DownloadQueue", qos: .utility, attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 1)

    func download() {
        
        print("DownloadQueue: started")
        
        let tasks = prepareTasks()
        
        for task in tasks {
            
            queue.async { [weak self] in
                
                guard let self = self else { return }
                
                self.semaphore.wait()
                
                task.handler.add(task.params, [:]) { result in
                    
                    switch result {
                    case .updated(let serial):
                        self.serialsStorage.store(serial: serial, of: task.kind)
                        print("DownloadQueue: \(type(of: task.handler)), serial: \(serial)")
                        
                    case .passed:
                        print("DownloadQueue: \(type(of: task.handler)) passed")
                    
                    case .failed(let error):
                        
                        if let error = error {
                            
                            print("DownloadQueue: \(type(of: task.handler)) failed, \(error.localizedDescription)")
                            
                        } else {
                            
                            print("DownloadQueue: \(type(of: task.handler)) failed")
                        }
                    }

                    self.semaphore.signal()
                }
            }
        }
    }
    
    func prepareTasks() -> [Task] {
        
        var queue = [Task]()
        
        // Countries list
        queue.append(Task(kind: .countryList,
                          handler: CountriesListSaved(),
                          params: ["serial" : serialsStorage.serial(for: .countryList)]))
        
        // Payments systems list
        queue.append(Task(kind: .paymentSystemList,
                          handler: GetPaymentSystemSaved(),
                          params: ["serial" : serialsStorage.serial(for: .paymentSystemList)]))
        
        // Currencies list
        queue.append(Task(kind: .currencyList,
                          handler: GetCurrencySaved(),
                          params: ["serial" : serialsStorage.serial(for: .currencyList)]))
        
        // Banks list
        queue.append(Task(kind: .bankList,
                          handler: BanksListSaved(),
                          params: ["serial" : serialsStorage.serial(for: .bankList), "type" : "", "bic":"", "serviceType": ""]))
        
        // Operators list
        queue.append(Task(kind: .operatorList,
                          handler: AddOperatorsList(),
                          params: ["serial" : serialsStorage.serial(for: .operatorList)]))
        
        // Session tiemout
        queue.append(Task(kind: .sessionTimeout,
                          handler: GetSessionTimeoutSaved(),
                          params: ["serial" : serialsStorage.serial(for: .sessionTimeout)]))
        
        downloadArray.append(GetPaymentSystemSaved())
        paramArray.append(paymentSystemParam)
        
        case sessionTimeout
        case countryList
        case paymentSystemList
        case currencyList
        case bankList
        case operatorList
        
        var key: String { "DownloadQueueStorage_\(rawValue)_Key"}
    }
    
    struct Task {

        let kind: Kind
        let handler: DownloadQueueProtocol
        let params: [String: String]
    }
    
    enum Result {
        
        case updated(String)
        case passed
        case failed(Error?)
    }
}
