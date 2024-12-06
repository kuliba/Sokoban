//
//  DownloadQueue.swift
//  Vortex
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
        
        let tasks = prepareTasks()
        
        for task in tasks {
            
            queue.async { [weak self] in
                
                guard let self = self else { return }
                
                self.semaphore.wait()
                
                task.handler.add(task.params, [:]) { result in
                    
                    switch result {
                    case .updated(let serial):
                        self.serialsStorage.store(serial: serial, of: task.kind)
                        
                    case .passed:
                        //TODO: set logger
                        break
                    
                    case .failed(let error):
                        
                        if let error = error {
                            //TODO: set logger
                            
                        } else {
                            //TODO: set logger

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
        
        return queue
    }
}
     
extension DownloadQueue {
    
    enum Kind: String {
        
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
