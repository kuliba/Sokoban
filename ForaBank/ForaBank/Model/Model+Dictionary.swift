//
//  Model+Dictionary.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation

//MARK: Data Helpers

extension Model {
    
    var dictionaryCurrencyList: [CurrencyData]? {
        
        return localAgent.load(type: [CurrencyData].self)
        
    }
    
    func currency(for currencyCode: Int) -> CurrencyData? {
        
        guard let dictionaryCurrencyList = dictionaryCurrencyList else {
            return nil
        }
        
        return dictionaryCurrencyList.first(where: {$0.codeNumeric == currencyCode})
        
    }
}

//MARK: - Actions

extension ModelAction {
    
    enum Dictionary {
        
        static let cached: [Kind] = [.anywayOperators, .fmsList, .fsspDebtList, .fsspDocumentList, .ftsList, .productCatalogList, .bannerCatalogList, .atmList, .atmServiceList, .atmTypeList, .atmMetroStationList, .atmCityList, .atmRegionList, .currencyList, .banks]
        
        enum UpdateCache {
            
            struct All: Action {}
            
            struct List: Action {
                
                let types: [Kind]
            }
            
            struct Request: Action {
                
                let type: Kind
                let serial: String?
            }
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
            case atmCityList
            case atmRegionList
        }
    }
}

//MARK: - Cache

extension Model {
    
    func dictionaryCheckCache(for dictionaryType: ModelAction.Dictionary.Kind) -> Bool {
        
        switch dictionaryType {
        case .anywayOperators:
            return localAgent.load(type: [OperatorGroupData].self) != nil
            
        case .banks:
            return localAgent.load(type: [BankData].self) != nil
            
        case .countries:
            return localAgent.load(type: [CountryData].self) != nil
            
        case .currencyList:
            return localAgent.load(type: [CurrencyData].self) != nil
            
        case .fmsList:
            return localAgent.load(type: [FMSData].self) != nil
            
        case .fsspDebtList:
            return localAgent.load(type: [FSSPDebtData].self) != nil
            
        case .fsspDocumentList:
            return localAgent.load(type: [FSSPDocumentData].self) != nil
            
        case .ftsList:
            return localAgent.load(type: [FTSData].self) != nil
            
        case .fullBankInfoList:
            return localAgent.load(type: [BankFullInfoData].self) != nil
            
        case .mobileList:
            return localAgent.load(type: [MobileData].self) != nil
            
        case .mosParkingList:
            return localAgent.load(type: [MosParkingData].self) != nil
            
        case .paymentSystemList:
            return localAgent.load(type: [PaymentSystemData].self) != nil
            
        case .productCatalogList:
            return localAgent.load(type: [CatalogProductData].self) != nil
            
        case .bannerCatalogList:
            return localAgent.load(type: [BannerCatalogListData].self) != nil
            
        case .atmList:
            return localAgent.load(type: [AtmData].self) != nil
            
        case .atmTypeList:
            return localAgent.load(type: [AtmTypeData].self) != nil
            
        case .atmServiceList:
            return localAgent.load(type: [AtmServiceData].self) != nil
            
        case .atmMetroStationList:
            return localAgent.load(type: [AtmMetroStationData].self) != nil
            
        case .atmCityList:
            return localAgent.load(type: [AtmCityData].self) != nil
            
        case .atmRegionList:
            return localAgent.load(type: [AtmRegionData].self) != nil
        }
    }
    
    func dictionaryCacheSerial(for dictionaryType: ModelAction.Dictionary.Kind) -> String? {
        
        switch dictionaryType {
        case .anywayOperators:
            return localAgent.serial(for: [OperatorGroupData].self)
            
        case .banks:
            return localAgent.serial(for: [BankData].self)
            
        case .countries:
            return localAgent.serial(for: [CountryData].self)
            
        case .currencyList:
            return localAgent.serial(for: [CurrencyData].self)
            
        case .fmsList:
            return localAgent.serial(for: [FMSData].self)
            
        case .fsspDebtList:
            return localAgent.serial(for: [FSSPDebtData].self)
            
        case .fsspDocumentList:
            return localAgent.serial(for: [FSSPDocumentData].self)
            
        case .ftsList:
            return localAgent.serial(for: [FTSData].self)
            
        case .fullBankInfoList:
            return localAgent.serial(for: [BankFullInfoData].self)
            
        case .mobileList:
            return localAgent.serial(for: [MobileData].self)
            
        case .mosParkingList:
            return localAgent.serial(for: [MosParkingData].self)
            
        case .paymentSystemList:
            return localAgent.serial(for: [PaymentSystemData].self)
            
        case .productCatalogList:
            return localAgent.serial(for: [CatalogProductData].self)
            
        case .bannerCatalogList:
            return localAgent.serial(for: [BannerCatalogListData].self)
            
        case .atmList:
            return localAgent.serial(for: [AtmData].self)
            
        case .atmTypeList:
            return localAgent.serial(for: [AtmTypeData].self)
            
        case .atmServiceList:
            return localAgent.serial(for: [AtmServiceData].self)
            
        case .atmMetroStationList:
            return localAgent.serial(for: [AtmMetroStationData].self)
            
        case .atmCityList:
            return localAgent.serial(for: [AtmCityData].self)
            
        case .atmRegionList:
            return localAgent.serial(for: [AtmRegionData].self)
        }
    }
    
    func dictionaryClearCache(for dictionaryType: ModelAction.Dictionary.Kind) {
        
        switch dictionaryType {
        case .anywayOperators:
            try? localAgent.clear(type: [OperatorGroupData].self)
            
        case .banks:
            try? localAgent.clear(type: [BankData].self)
            
        case .countries:
            try? localAgent.clear(type: [CountryData].self)
            
        case .currencyList:
            try? localAgent.clear(type: [CurrencyData].self)
            
        case .fmsList:
            try? localAgent.clear(type: [FMSData].self)
            
        case .fsspDebtList:
            try? localAgent.clear(type: [FSSPDebtData].self)
            
        case .fsspDocumentList:
            try? localAgent.clear(type: [FSSPDocumentData].self)
            
        case .ftsList:
            try? localAgent.clear(type: [FTSData].self)
            
        case .fullBankInfoList:
            try? localAgent.clear(type: [BankFullInfoData].self)
            
        case .mobileList:
            try? localAgent.clear(type: [MobileData].self)
            
        case .mosParkingList:
            try? localAgent.clear(type: [MosParkingData].self)
            
        case .paymentSystemList:
            try? localAgent.clear(type: [PaymentSystemData].self)
            
        case .productCatalogList:
            try? localAgent.clear(type: [CatalogProductData].self)
            
        case .bannerCatalogList:
            try? localAgent.clear(type: [BannerCatalogListData].self)
            
        case .atmList:
            try? localAgent.clear(type: [AtmData].self)
            
        case .atmTypeList:
            try? localAgent.clear(type: [AtmTypeData].self)
            
        case .atmServiceList:
            try? localAgent.clear(type: [AtmServiceData].self)
            
        case .atmMetroStationList:
            try? localAgent.clear(type: [AtmMetroStationData].self)
            
        case .atmCityList:
            try? localAgent.clear(type: [AtmCityData].self)
            
        case .atmRegionList:
            try? localAgent.clear(type: [AtmRegionData].self)
        }
    }
}

//MARK: - Data Helpers

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

//MARK: - Reducers

extension Model {
    
    static func dictionaryAtmReduce(current: [AtmData], update: [AtmData]) -> [AtmData] {
        
        var updated = current
        
        // insert items
        let insertedItems = update.filter{ $0.action == .insert }
        updated.append(contentsOf: insertedItems)
        
        // delete items
        let deletedItems = update.filter({ $0.action == .delete }).map{ $0.id }
        updated = updated.filter({ deletedItems.contains($0.id) == false})
        
        // update items
        let updatedItems = update.filter({ $0.action == .update })
        return updated.map({ item in
            
            if let updatedItem = updatedItems.first(where: { $0.id == item.id }) {
                
                return updatedItem
                
            } else {
                
                return item
            }
        })
    }
}

//MARK: - Handlers

extension Model {
    
    // Update all cached
    func handleDictionaryUpdateAll()  {
        
        action.send(ModelAction.Dictionary.UpdateCache.List(types: ModelAction.Dictionary.cached))
    }
    
    // Update list
    
    func handleDictionaryUpdateList(_ payload: ModelAction.Dictionary.UpdateCache.List) {
        
        for type in payload.types {
            
            if dictionaryCheckCache(for: type) == true {
                
                action.send(ModelAction.Dictionary.UpdateCache.Request(type: type, serial: dictionaryCacheSerial(for: type)))
                
            } else {
                
                dictionaryClearCache(for: type)
                action.send(ModelAction.Dictionary.UpdateCache.Request(type: type, serial: nil))
            }
        }
    }
    
    
    // Anyway Operators
    func handleDictionaryAnywayOperatorsRequest(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetAnywayOperatorsList(serial: serial)
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
    func handleDictionaryBanks(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetBanks(serial: serial)
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
                    
                    self.bankList.value = data.banksList
                    
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
    func handleDictionaryCountries(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetCountries(serial: serial)
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
    func handleDictionaryCurrencyList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetCurrencyList(serial: serial)
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
                    
                    self.currencyList = data.currencyList
                    
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
    func handleDictionaryFMSList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFMSList(serial: serial)
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
    func handleDictionaryFSSPDebtList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFSSPDebtList(serial: serial)
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
    func handleDictionaryFSSPDocumentList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFSSPDocumentList(serial: serial)
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
    func handleDictionaryFTSList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFTSList(serial: serial)
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
    func handleDictionaryFullBankInfoList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetFullBankInfoList(serial: serial)
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
    func handleDictionaryMobileList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetMobileList(serial: serial)
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
    func handleDictionaryMosParkingList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetMosParkingList(serial: serial)
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
    func handleDictionaryPaymentSystemList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetPaymentSystemList(serial: serial)
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
    func handleDictionaryProductCatalogList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetProductCatalogList(serial: serial)
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
    func handleDictionaryBannerCatalogList(_ serial: String?) {
        
        let command = ServerCommands.DictionaryController.GetBannerCatalogList(serial: serial)
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
    func handleDictionaryAtmDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetAtmList(serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    var atmDataSource = [AtmData]()
                    
                    // load items from cache if exists
                    if let cached = self.localAgent.load(type: [AtmData].self)  {
                        atmDataSource.append(contentsOf: cached)
                    }
                    
                    let result = Self.dictionaryAtmReduce(current: atmDataSource, update: data.list)
                    
                    do {
                        
                        try self.localAgent.store(result, serial: "\(data.version)")
                        
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
    func handleDictionaryAtmServiceDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetAtmServiceList(serial: serial)
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
    func handleDictionaryAtmTypeDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetAtmTypeList(serial: serial)
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
    func handleDictionaryAtmMetroStationDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetMetroStationList(serial: serial)
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
    
    //AtmCityDataList
    func handleDictionaryAtmCityDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetCityList(serial: serial)
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
    
    //AtmRegionDataList
    func handleDictionaryAtmRegionDataList(_ serial: String?) {
        
        let command = ServerCommands.AtmController.GetRegionList(serial: serial)
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

