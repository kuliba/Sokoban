//
//  Model+Dictionary.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Dictionary {

        enum AnywayOperators {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum Banks {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum Countries {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum CurrencyList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum FMSList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum FSSPList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum FTSList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum FullBankInfoList {
            
            struct Requested: Action {
                
                let serial: String?
                let bic: String
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum MobileList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum MosParkingList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        enum PaymentSystemList {
            
            struct Requested: Action {
                
                let serial: String?
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    // Anyway Operators
    
    func handleDictionaryAnywayOperatorsRequest(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetAnywayOperatorsList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.operatorGroupList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
    }
    
    //GetBanks
    
    func handleDictionaryGetBanks(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetBanks(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.banksList, serial: data.serial)
                        
                    } catch {
                    
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
    }
    
    //Countries
    
    func handleDictionaryCountries(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetCountries(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.countriesList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
    }
    
    //CurrencyList
    
    func handleDictionaryCurrencyList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetCurrencyList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.currencyList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
    }
    
    //GetFMSList
    
    func handleDictionaryFMSList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFMSList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.fmsList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
    }
    
    //GetFSSPList
    
    //FIXME: refactor
    func handleDictionaryFSSPList(serial: String?) {
        
        /*
        let command = ServerCommands.DictionaryController.GetFSSPList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.fsspList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)
            }
        }
         */
    }
    
    //GetFTSList
    
    func handleDictionaryFTSList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFTSList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleDictionaryDownloadEmptyData(command: command)
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.ftsList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)

            }
        }
    }
    
    //GetFullBankInfoList
    
    func handleDictionaryFullBankInfoList(bic: String, serial: String?) {
        
            let command = ServerCommands.DictionaryController.GetFullBankInfoList(bic: bic, name: nil, engName: nil, type: nil, account: nil, swift: nil, serviceType: nil, serial: serial)
            serverAgent.executeCommand(command: command) {[unowned self] result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let data = response.data else {
                            
                            handleDictionaryDownloadEmptyData(command: command)
                            return
                        }
                        
                        do {
                            
                            try self.localAgent.store(data.bankFullInfoList, serial: data.serial)
                            
                        } catch {
                            
                            handleDictionaryCachingError(error: error, command: command)
                        }
                        
                    default:
                        self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    }
                    
                case .failure(let error):
                    handleDictionaryDownloadError(error: error, command: command)
                }
            }
        }
    
    //GetMobileList
    
    func handleDictionaryMobileList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetMobileList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.mobileList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)

            }
        }
    }
    
    //GetMosParkingList
    
    func handleDictionaryMosParkingList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetMosParkingList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.mosParkingList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)

            }
        }
    }
    
    //GetPaymentSystemList
    
    func handleDictionaryPaymentSystemList(serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetPaymentSystemList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.paymentSystemList, serial: data.serial)
                        
                    } catch {
                        
                        handleDictionaryCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handle(serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleDictionaryDownloadError(error: error, command: command)

            }
        }
    }
    
    func handleDictionaryDownloadError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("DownloadError: \(error.localizedDescription), command: \(command)")
        
    }
    
    func handleDictionaryCachingError<Command: ServerCommand>(error: Error, command: Command) {
        
        print("CachingError: \(error.localizedDescription), command: \(command)")
    }
    
    func handleDictionaryDownloadEmptyData<Command: ServerCommand>(command: Command){
        
        print("DownloadEmptyData command: \(command)")
    }
}
