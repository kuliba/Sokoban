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
        
        static let cached: [Kind] = [.anywayOperators, .fmsList, .fsspDebtList, .fsspDocumentList, .ftsList, .productCatalogList, .bannerCatalogList, .atmList, .atmServiceList, .atmTypeList, .atmMetroStationList]

        struct Request: Action {
            
            let type: Kind
            let serial: String?
        }
        
        enum Kind: CaseIterable {
            
            case anywayOperators
            case banks
            case countries
            case currencyList
            case fmsList
            case fsspDebtList
            case fsspDocumentList
            case ftsList
            case fullBankInfoList
            case mobileList
            case mosParkingList
            case paymentSystemList
            case productCatalogList
            case bannerCatalogList
            case atmList
            case atmServiceList
            case atmTypeList
            case atmMetroStationList
        }
    }
}

extension Model {
    
    func dictionaryAnywayOperatorGroups() -> [OperatorGroupData]? {
        
        return localAgent.load(type: [OperatorGroupData].self)
    }
    
    func dictionaryAnywayOperators() -> [OperatorGroupData.OperatorData]? {
        
        guard let anywayOperatorGroups = dictionaryAnywayOperatorGroups() else {
            return nil
        }
        
        return anywayOperatorGroups.flatMap{ $0.operators }
    }
    
    func dictionaryAnywayOperatorGroup(for code: String) -> OperatorGroupData? {
        
        guard let anywayOperatorGroups = dictionaryAnywayOperatorGroups() else {
            return nil
        }
        
        return anywayOperatorGroups.first(where: { $0.code == code })
    }
    
    func dictionaryAnywayOperator(for code: String) -> OperatorGroupData.OperatorData? {
        
        guard let anywayOperators = dictionaryAnywayOperators() else {
            return nil
        }
        
        return anywayOperators.first(where: { $0.code == code })
    }
    
    func dictionaryFMSList() -> [FMSData]? {
        
        return localAgent.load(type: [FMSData].self)
    }
    
    func dictionaryFTSList() -> [FTSData]? {
        
        return localAgent.load(type: [FTSData].self)
    }
    
    func dictionaryFSSPDocumentList() -> [FSSPDocumentData]? {
        
        return localAgent.load(type: [FSSPDocumentData].self)
    }
    
    func dictionaryAtmList() -> [AtmData]? {
        
        return localAgent.load(type: [AtmData].self)
    }
    
    func dictionaryAtmMetroStations() -> [AtmMetroStationData]? {
        
        return localAgent.load(type: [AtmMetroStationData].self)
    }
    
    func dictionaryAtmServices() -> [AtmServiceData]? {

        return localAgent.load(type: [AtmServiceData].self)
    }
}

//MARK: - Handlers

extension Model {
    
    // Anyway Operators
    func handleDictionaryAnywayOperatorsRequest(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetAnywayOperatorsList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.operatorGroupList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.operatorGroupList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // Banks
    func handleDictionaryBanks(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetBanks(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.banksList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.banksList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // Countries
    func handleDictionaryCountries(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetCountries(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.countriesList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.countriesList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // CurrencyList
    func handleDictionaryCurrencyList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetCurrencyList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.currencyList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.currencyList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // FMSList
    func handleDictionaryFMSList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetFMSList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.fmsList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.fmsList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // FSSPDebtList
    func handleDictionaryFSSPDebtList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetFSSPDebtList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.fsspDebtList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.fsspDebtList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // FSSPDocumentList
    func handleDictionaryFSSPDocumentList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetFSSPDocumentList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.fsspDocumentList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.fsspDocumentList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // FTSList
    func handleDictionaryFTSList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetFTSList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.ftsList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.ftsList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    // FullBankInfoList
    func handleDictionaryFullBankInfoList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetFullBankInfoList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.bankFullInfoList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.bankFullInfoList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // MobileList
    func handleDictionaryMobileList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetMobileList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        return
                    }
                    
                    // check if we have updated data
                    guard data.mobileList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.mobileList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    // MosParkingList
    func handleDictionaryMosParkingList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetMosParkingList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.mosParkingList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.mosParkingList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    // PaymentSystemList
    func handleDictionaryPaymentSystemList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetPaymentSystemList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.paymentSystemList.count > 0 else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.paymentSystemList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    // ProductCatalogList
    func handleDictionaryProductCatalogList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetProductCatalogList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.productCatalogList.count > 0 else {
                        return
                    }
                    
                    self.catalogProducts.value = data.productCatalogList
                    
                    do {
                        
                        try self.localAgent.store(data.productCatalogList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    //BannerCatalogListData
    func handleDictionaryBannerCatalogList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.DictionaryController.GetBannerCatalogList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.BannerCatalogList.count > 0 else {
                        return
                    }
                    
                    self.catalogBanners.value = data.BannerCatalogList
                    
                    do {
                        
                        try self.localAgent.store(data.BannerCatalogList, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                
            }
        }
    }
    
    //AtmDataList
    func handleDictionaryAtmDataList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.AtmController.GetAtmList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    var updated = [AtmData]()
                    
                    // load items from cache if exists
                    if let cached = self.localAgent.load(type: [AtmData].self)  {
                        updated.append(contentsOf: cached)
                    }
                    
                    // insert items
                    let insertedItems = data.list.filter{ $0.action == .insert }
                    updated.append(contentsOf: insertedItems)
                    
                    // delete items
                    let deletedItems = data.list.filter({ $0.action == .delete }).map{ $0.id }
                    updated = updated.filter({ deletedItems.contains($0.id) == false})
                    
                    // update items
                    let updatedItems = data.list.filter({ $0.action == .update })
                    updated = updated.map({ item in
                        
                        if let updatedItem = updatedItems.first(where: { $0.id == item.id }) {
                            
                            return updatedItem
                            
                        } else {
                            
                            return item
                        }
                    })
                    
                    do {
 
                        try self.localAgent.store(updated, serial: "\(data.version)")
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    //AtmServiceDataList
    func handleDictionaryAtmServiceDataList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.AtmController.GetAtmServiceList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else {
                        return
                    }
                    
                    do {
 
                        try self.localAgent.store(data.list, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    //AtmTypeDataList
    func handleDictionaryAtmTypeDataList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.AtmController.GetAtmTypeList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else {
                        return
                    }
                    
                    do {
 
                        try self.localAgent.store(data.list, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    //AtmMetroStationDataList
    func handleDictionaryAtmMetroStationDataList(_ payload: ModelAction.Dictionary.Request) {
        
        let command = ServerCommands.AtmController.GetMetroStationList(serial: payload.serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else {
                        return
                    }
                    
                    do {
 
                        try self.localAgent.store(data.list, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
}
