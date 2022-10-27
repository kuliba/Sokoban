//
//  Model+Rates.swift
//  ForaBank
//
//  Created by Max Gribov on 25.05.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Rates {
    
        enum Update {
            
            struct All: Action {}
            
            struct Single: Action {
                
                let currency: Currency
            }
            
            struct List: Action {
                
                let currencyList: [Currency]
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleRateUpdate(_ productCurrency: Currency) {
        
        handleRatesUpdate([productCurrency])
    }
    
    func handleRatesUpdate(_ productsCurrency: [Currency]) {
        
        guard self.ratesUpdating.value.isEmpty == true else {
            return
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        Task {
            
            self.ratesUpdating.value = productsCurrency
            
            for currency in productsCurrency {
                
                let command = ServerCommands.RatesController.GetExchangeCurrencyRates(token: token, currency: currency)
                             
                do {
                    
                    let result = try await ratesFetchWithCommand(command: command)
  
                    // updating status
                    if let index = self.ratesUpdating.value.firstIndex(of: currency) {
                        
                        self.ratesUpdating.value.remove(at: index)
                    }

                    // update rates
                    self.rates.value = reduce(rates: self.rates.value, with: result)

                    // cache products
                    try localAgent.store(rates.value, serial: nil)

                } catch {
            
                    // updating status
                    if let index = self.ratesUpdating.value.firstIndex(of: currency) {
                        
                        self.ratesUpdating.value.remove(at: index)
                    }
                    
                    self.handleServerCommandError(error: error, command: command)
                    //TODO: show error message in UI
                }
            }
        }
    }
    
    func ratesFetchWithCommand(command: ServerCommands.RatesController.GetExchangeCurrencyRates) async throws -> ExchangeRateData {
        
        try await withCheckedThrowingContinuation { continuation in
            
            serverAgent.executeCommand(command: command) { result in
                switch result{
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        
                        guard let data = response.data else {
                            continuation.resume(with: .failure(ModelRatesError.emptyData(message: response.errorMessage)))
                            return
                        }
                        
                        continuation.resume(returning: data)

                    default:
                        continuation.resume(with: .failure(ModelRatesError.statusError(status: response.statusCode, message: response.errorMessage)))
                    }
                case .failure(let error):
                    continuation.resume(with: .failure(ModelRatesError.serverCommandError(error: error.localizedDescription)))
                }
            }
        }
    }
}

extension Model {
    
    func reduce(rates: [ExchangeRateData], with updatedRate: ExchangeRateData) -> [ExchangeRateData] {
        
        var updated = [ExchangeRateData]()
        
        for rate in rates {
            
            if rate.currency == updatedRate.currency {
                
                updated.append(updatedRate)
                
            } else {
                
                updated.append(rate)
            }
        }
        
        if updated.contains(updatedRate) == false {
            
            updated.append(updatedRate)
        }
        
        return updated
    }
}

//MARK: - Error

enum ModelRatesError: Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: String)
    case unableCacheUnknownProductType
    case clearCacheErrors([Error])
}
