//
//  Model+Dictionary.swift
//  ForaBank
//
//  Created by Max Gribov on 05.02.2022.
//

import Foundation
import ServerAgent

// MARK: - Actions

extension ModelAction {
    
    enum Dictionary {
        
        enum UpdateCache {
            
            struct All: Action {}
            
            struct List: Action {
                
                let types: [DictionaryType]
            }
            
            struct Request: Action {
                
                let type: DictionaryType
                let serial: String?
            }
        }
        
        enum DownloadImages {
            
            struct Request: Action {
                
                let imagesIds: [String]
            }
            
            struct Response: Action {
                
                let result: Result<[(id: String, imageData: ImageData)], Error>
            }
        }
        
        enum AnywayOperator {
            
            struct Request: Action {
                
                let code: String
                let codeParent: String
            }
            
            struct Response: Action {
                
                let result: Result<[AnywayOperatorData], Error>
            }
        }
        
        static let cached: [DictionaryType] = [
            .anywayOperators,
            .fmsList,
            .fsspDebtList,
            .fsspDocumentList,
            .ftsList,
            .productCatalogList,
            .bannerCatalogList,
            .atmList,
            .atmServiceList,
            .atmTypeList,
            .atmMetroStationList,
            .atmCityList,
            .atmRegionList,
            .currencyList,
            .currencyWalletList,
            .countries,
            .countriesWithService,
            .banks,
            .paymentSystemList,
            .fullBankInfoList,
            .qrMapping,
            .qrPaymentType,
            .prefferedBanks,
            .clientInform
        ]
    }
}

// MARK: - Cache

extension Model {
    
    func dictionaryCheckCache(for dictionaryType: DictionaryType) -> Bool {
        
        switch dictionaryType {
        case .anywayOperators:
            return localAgent.load(type: [OperatorGroupData].self) != nil
            
        case .banks:
            return localAgent.load(type: [BankData].self) != nil
            
        case .countries:
            return localAgent.load(type: [CountryData].self) != nil
            
        case .countriesWithService:
            return localAgent.load(type: [CountryWithServiceData].self) != nil
            
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
            
        case .bannersMyProductListWithSticker:
            return localAgent.load(type: [StickerBannersMyProductList].self) != nil
            
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
            
        case .currencyWalletList:
            return localAgent.load(type: [CurrencyWalletData].self) != nil
            
        case .centralBanksRates:
            return localAgent.load(type: [CentralBankRatesData].self) != nil
            
        case .qrMapping:
            return localAgent.load(type: QRMapping.self) != nil
            
        case .qrPaymentType:
            return localAgent.load(type: QRPaymentType.self) != nil
            
        case .prefferedBanks:
            return localAgent.load(type: [PrefferedBanksList].self) != nil
            
        case .clientInform:
            return localAgent.load(type: ClientInformData.self) != nil
        }
    }
    
    func dictionaryCacheSerial(for dictionaryType: DictionaryType) -> String? {
        
        switch dictionaryType {
        case .anywayOperators:
            return localAgent.serial(for: [OperatorGroupData].self)
            
        case .banks:
            return localAgent.serial(for: [BankData].self)
            
        case .countries:
            return localAgent.serial(for: [CountryData].self)
            
        case .countriesWithService:
            return localAgent.serial(for: [CountryWithServiceData].self)
            
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
            
        case .bannersMyProductListWithSticker:
            return localAgent.serial(for: [StickerBannersMyProductList].self)
            
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
            
        case .currencyWalletList:
            return localAgent.serial(for: [CurrencyWalletData].self)
            
        case .centralBanksRates:
            return localAgent.serial(for: [CentralBankRatesData].self)
            
        case .qrMapping:
            return localAgent.serial(for: QRMapping.self)
            
        case .qrPaymentType:
            return localAgent.serial(for: QRPaymentType.self)
            
        case .prefferedBanks:
            return localAgent.serial(for: [PrefferedBanksList].self)
            
        case .clientInform:
            return localAgent.serial(for: ClientInformData.self)
        }
    }
    
    func dictionaryClearCache(for dictionaryType: DictionaryType) {
        
        switch dictionaryType {
        case .anywayOperators:
            try? localAgent.clear(type: [OperatorGroupData].self)
            
        case .banks:
            try? localAgent.clear(type: [BankData].self)
            
        case .countries:
            try? localAgent.clear(type: [CountryData].self)
            
        case .countriesWithService:
            try? localAgent.clear(type: [CountryWithServiceData].self)
            
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
            
        case .bannersMyProductListWithSticker:
            try? localAgent.clear(type: [StickerBannersMyProductList].self)
            
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
            
        case .currencyWalletList:
            try? localAgent.clear(type: [CurrencyWalletData].self)
            
        case .centralBanksRates:
            try? localAgent.clear(type: [CentralBankRatesData].self)
            
        case .qrMapping:
            try? localAgent.clear(type: QRMapping.self)
            
        case .qrPaymentType:
            try? localAgent.clear(type: QRPaymentType.self)
            
        case .prefferedBanks:
            try? localAgent.clear(type: [PrefferedBanksList].self)
            
        case .clientInform:
            try? localAgent.clear(type: ClientInformData.self)
        }
    }
}

// MARK: - Data Helpers

extension Model {
    
    func dictionaryCurrency(for currencyCode: Int) -> CurrencyData? {
        
        return currencyList.value.first(where: { $0.codeNumeric == currencyCode })
    }
    
    func dictionaryCurrency(for code: String) -> CurrencyData? {
        
        return currencyList.value.first(where: { $0.code == code })
    }
    
    func dictionaryCurrencySymbol(for code: String) -> String? {
        
        dictionaryCurrency(for: code)?.currencySymbol
    }
    
    // MARK: BankList helper
    
    var dictionaryBankList: [BankData] {
        
        return bankList.value
    }
    
    func isForaBank(bankId: BankData.ID) -> Bool {
        
        bankId == BankID.foraBankID.rawValue
    }
    
    // MARK: Operators & OperatorGroups
    
    static let dictionaryQRAnywayOperatorCodes = ["iFora||1031001",
                                                  "iFora||1051001",
                                                  "iFora||1051062",
                                                  "iFora||1331001"]
    
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
    
    func dictionaryAnywayGroupOperatorData(for operatorCode: String) -> OperatorGroupData.OperatorData? {
        
        guard let anywayOperatorGroups = dictionaryAnywayOperatorGroups() else {
            return nil
        }
        
        for item in anywayOperatorGroups {
            
            return item.operators.first(where: {$0.code == operatorCode})
        }
        
        return nil
    }
    
    func dictionaryAnywayOperator(for code: String) -> OperatorGroupData.OperatorData? {
        
        guard let anywayOperators = dictionaryAnywayOperators() else {
            return nil
        }
        
        return anywayOperators.first(where: { $0.code == code })
    }
    
    func dictionaryQRAnewayOperator() -> [OperatorGroupData.OperatorData] {
        
        guard let operators = dictionaryAnywayOperators() else { return [] }
        
        var operatorsTemp = [OperatorGroupData.OperatorData]()
        
        for item in operators {
            
            if Self.dictionaryQRAnywayOperatorCodes.contains(item.parentCode) {
                operatorsTemp.append(item)
            }
        }
        
        return operatorsTemp
    }
    
    //Banks
    
    func dictionaryBanks() -> [BankData]? {
        
        bankList.value
    }
    
    func dictionaryBank(for memberId: String) -> BankData? {
        
        guard let banksList = dictionaryBanks() else { return nil }
        return banksList.first(where: { $0.memberId == memberId })
    }
    
    // FullBankInfoList
    
    func dictionaryFullBankInfoList() -> [BankFullInfoData] {
        
        bankListFullInfo.value
    }
    
    func dictionaryFullBankInfoBank(for bic: String) -> BankFullInfoData? {
        
        let banksList = dictionaryFullBankInfoList()
        return banksList.first(where: { $0.bic == bic })
    }
    
    func dictionaryFullBankInfoPrefferedFirstList() -> [BankFullInfoData] {
        
        let banksList = bankListFullInfo.value
        
        let prefferedBanks = prefferedBanksList.value.compactMap { bankId in banksList.first(where: { $0.memberId == bankId }) }
        
        //TODO: not sure if we need here two sorts. Test it first.
        let otherBanks = banksList.filter { !prefferedBanks.contains($0) }
            .sorted(by: { $0.displayName.lowercased() < $1.displayName.lowercased() })
            .sorted(by: { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending })
        
        return prefferedBanks + otherBanks
    }
    
    // Region
    
    func dictionaryRegion(for region: String) -> [OperatorGroupData.OperatorData] {
        
        guard let regionList = dictionaryAnywayOperators() else { return [] }
        
        let regions = regionList.filter{ $0.region == region }
        
        return regions
    }
    
    // Region + parent code
    
    func dictionaryRegion(for region: String, code: String) -> [OperatorGroupData.OperatorData] {
        
        guard let regionList = dictionaryAnywayOperators() else { return [] }
        
        let regions = regionList.filter{ $0.region == region && $0.parentCode == code }
        
        return regions
    }
    
    //Countries
    
    func dictionaryCountries() -> [CountryData]? {
        
        return localAgent.load(type: [CountryData].self)
    }
    
    func dictionaryCountry(for code: String) -> CountryData? {
        
        guard let countries = dictionaryCountries() else { return nil }
        return countries.first(where: { $0.code == code })
    }
    
    //FMSList
    
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

// MARK: - Reducers

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
    
    func dictionaryImagesReduce(images: [String: ImageData], updateItems: [(id: String, image: ImageData)]) -> [String: ImageData] {
        
        var imagesUpdated = images
        
        for item in updateItems {
            
            imagesUpdated[item.id] = item.image
        }
        
        return imagesUpdated
    }
}

// MARK: - Handlers

extension Model {
    
    // Update all cached
    func handleDictionaryUpdateAll()  {
        
        action.send(ModelAction.Dictionary
            .UpdateCache.List(types: ModelAction.Dictionary.cached))
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
        
        Task {
            
            do {
                let get = Services.getOperatorsListByParam(httpClient: self.authenticatedHTTPClient())
                let data = try await get.process((serial, "housingAndCommunalService")).get()
                
                if !data.isEmpty {
                    
                    cache(data, serial: serial)
                }
            } catch {
                
                LoggerAgent().log(category: .cache, message: "Invalid data for getOperatorsListByParam")

            }
        }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .anywayOperators
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetAnywayOperatorsList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
    
    func handleAnywayOperatorsCountryRequest(code: String, codeParent: String) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .anywayOperators
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetDictionaryAnywayOperators(token: token, code: code, codeParent: codeParent)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    guard let dictionaryList = data.list.first?.dictionaryList else {
                        return
                    }
                    
                    self.action.send(ModelAction.Dictionary.AnywayOperator.Response(result: .success(dictionaryList)))
                    
                default:
                    self.action.send(ModelAction.Dictionary.AnywayOperator.Response(result: .failure(ModelError.statusError(status:  response.statusCode, message: response.errorMessage))))
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Dictionary.AnywayOperator.Response(result: .failure(error)))
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // MARK: - Banks
    
    func handleDictionaryBanks(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .banks
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetBanks(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
    
    // MARK: - Preffered Banks
    
    func handleDictionaryPrefferedBanks(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .prefferedBanks
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetPrefferdBanksList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else {
                        return
                    }
                    
                    self.prefferedBanksList.value = data.list
                    
                    do {
                        
                        try self.localAgent.store(data, serial: data.serial)
                        
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .countries
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetCountries(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
                    
                    countriesList.value = data.countriesList
                    
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
    
    //CountryWithService
    func handleDictionaryCountryWithService(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .countriesWithService
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        //FIXME: have problem with serial not clean after remove app
        let command = ServerCommands.DictionaryController.GetCountriesWithServices(token: token, serial: nil)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else {
                        return
                    }
                    
                    countriesListWithSevice.value = data.list
                    
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
    
    // CurrencyWalletList
    func handleDictionaryCurrencyWalletList(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .currencyWalletList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands
            .DictionaryController
            .GetCurrencyWalletList(token: token, serial: serial)
        
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data
                    else {
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.list.count > 0 else { return }
                    
                    self.currencyWalletList.value = data.list
                    
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
    
    // CentralBankRates
    func handleDictionaryCentralBankRates() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .centralBanksRates
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands
            .DictionaryController
            .GetCentralBankRates(token: token)
        
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data
                    else {
                        handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.centralBankRates.value = data.ratesCb
                    
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .currencyList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetCurrencyList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
                    
                    self.currencyList.value = data.currencyList
                    
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .fmsList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetFMSList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .fsspDebtList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetFSSPDebtList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .fsspDocumentList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetFSSPDocumentList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .ftsList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetFTSList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .fullBankInfoList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetFullBankInfoList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
                    
                    self.bankListFullInfo.value = data.bankFullInfoList
                    
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .mobileList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetMobileList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .mosParkingList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetMosParkingList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .paymentSystemList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetPaymentSystemList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
                    
                    paymentSystemList.value = data.paymentSystemList
                    
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .productCatalogList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetProductCatalogList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
    
    // Get BannersMyProductList, with Sticker
    func handleDictionaryBannersMyProductListWithSticker(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .bannersMyProductListWithSticker
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetBannersMyProductListWithSticker(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    guard data.stickerCardData.count > 0 else {
                        return
                    }
                    
                    self.productListBannersWithSticker.value = data.stickerCardData
                    if let md5hashImage = data.stickerCardData.first?.md5hash {
                        
                        self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [md5hashImage]))
                    }
                   
                    do {
                        
                        try self.localAgent.store(data.stickerCardData, serial: data.serial)
                        
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
        
        guard let token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let typeDict: DictionaryType = .bannerCatalogList
        
        guard !dictionariesUpdating.value.contains(typeDict) else { return }
        
        dictionariesUpdating.value.insert(typeDict)

        let command = ServerCommandsGetBannerCatalogList(token: token, serial: serial)

        if let getBannerCatalogListV2 {
            getBannerCatalogList(getBannerCatalogListV2, command, serial, typeDict)
        } else {
            getBannerCatalogListV1(command, serial, typeDict)
        }
    }
        
    func getBannerCatalogListV1(
        _ command: ServerCommandsGetBannerCatalogList,
        _ serial: String?,
        _ typeDict: DictionaryType
    ) {
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            self.handleGetBannerCatalogListV1Response(command, result)
        }
    }
    
    func getBannerCatalogList(
        _ getBannerCatalogListCommand: Services.GetBannerCatalogList,
        _ command: ServerCommandsGetBannerCatalogList,
        _ serial: String?,
        _ typeDict: DictionaryType
    ) {
        getBannerCatalogListCommand(serial) { [weak self] result in
            
            self?.dictionariesUpdating.value.remove(typeDict)
            self?.handleGetBannerCatalogListV2Response(command, result)
        }
    }
    
    func handleGetBannerCatalogListV2Response (
        _ command: ServerCommandsGetBannerCatalogList,
        _ result: Services.GetBannerCatalogListV1Response?
    ) {
        switch result {
            
        case .none:
            handleServerCommandEmptyData(command: command)

        case let .some(response):
            guard !response.bannerCatalogList.isEmpty
            else {
                return
            }
            
            catalogBanners.value = response.bannerCatalogList
            catalogBannersCacheStore(command, response)
        }
    }

    func handleGetBannerCatalogListV1Response (
        _ command: ServerCommandsGetBannerCatalogList,
        _ result: Result<ServerCommandsGetBannerCatalogList.Response, ServerAgentError>
    ) {
        switch result {
        case let .success(response):
            switch response.statusCode {
            case .ok:
                guard let data = response.data,
                      !data.bannerCatalogList.isEmpty
                else {
                    return
                }
                
                catalogBanners.value = data.bannerCatalogList
                catalogBannersCacheStore(command, data)
                
            default:
                handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
            }
            
        case let .failure(error):
            handleServerCommandError(error: error, command: command)
        }
    }
    
    func catalogBannersCacheStore(
        _ command: ServerCommandsGetBannerCatalogList,
        _ data: ServerCommandsGetBannerCatalogList.Response.BannerCatalogData) {
        do {
            
            try localAgent.store(data.bannerCatalogList, serial: data.serial)
            
        } catch {
            
            handleServerCommandCachingError(error: error, command: command)
        }
    }
    
    //AtmDataList
    func handleDictionaryAtmDataList(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetAtmList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data else {
                        return
                    }
                    
                    do {
                        
                        try self.localAgent.store(data.list, serial: "\(data.version)")
                        
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmServiceList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetAtmServiceList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmTypeList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetAtmTypeList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmMetroStationList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetMetroStationList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmCityList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetCityList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .atmRegionList
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.AtmController.GetRegionList(token: token, serial: serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
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
    
    //QRMapping
    func handleDictionaryQRMapping(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.QRController.GetPaymentsMapping(token: token, serial: serial)
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard data.qrMapping.parameters.isEmpty == false,
                          data.qrMapping.operators.isEmpty == false else {
                        
                        return
                    }
                    
                    qrMapping.value = data.qrMapping
                    
                    do {
                        
                        try localAgent.store(data.qrMapping, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // QRPaymentType
    func handleDictionaryQRPaymentType(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.QRController.GetQRPaymentType(
            token: token,
            serial: serial
        )
        serverAgent.executeCommand(command: command) { [unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let data = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    // check if we have updated data
                    guard !data.list.isEmpty else { return }

                    qrPaymentType.value = data.list
                    
                    do {
                        
                        try localAgent.store(data.list, serial: data.serial)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    // ClientInform
    func handleClientInform(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let typeDict: DictionaryType = .clientInform
        guard !self.dictionariesUpdating.value.contains(typeDict) else { return }
        self.dictionariesUpdating.value.insert(typeDict)
        
        let command = ServerCommands.DictionaryController.GetClientInformData(token: token, serial: nil)   //befor refactoring back -  <nil>, after serial)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            self.dictionariesUpdating.value.remove(typeDict)
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    self.clientInform.value = .result(response.data)
                    
                default:
                    self.clientInform.value = .result(nil)
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.clientInform.value = .result(nil)
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    //DownloadImages
    func handleDictionaryDownloadImages(payload: ModelAction.Dictionary.DownloadImages.Request) {
        
        guard let payload = payload.cleaned() else { return }
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.DictionaryController
            .GetSvgImageList(token: token,
                             payload: .init(md5HashList: payload.imagesIds))
        
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let data = response.data
                    else {
                        handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Dictionary.DownloadImages.Response(result: .failure(ModelDictionaryError.emptyData(message: response.errorMessage))))
                        return
                    }
                    
                    let responseItems: [(String, ImageData)] = data.svgImageList.compactMap { item in
                        
                        guard let imageData = ImageData(with: item.svgImage) else {
                            return nil
                        }
                        
                        return (item.md5hash, imageData)
                    }
                    
                    self.action.send(ModelAction.Dictionary.DownloadImages.Response.init(result: .success(responseItems)))
                    
                    // if there is no images do not update cache
                    guard responseItems.isEmpty == false else {
                        return
                    }
                    
                    self.images.value = dictionaryImagesReduce(images: self.images.value, updateItems: responseItems)
                    
                    do {
                        
                        try self.localAgent.store(images.value, serial: nil)
                        
                    } catch {
                        
                        handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    self.action.send(ModelAction.Dictionary.DownloadImages.Response(result: .failure(ModelDictionaryError.statusError(status: response.statusCode, message: response.errorMessage))))
                }
                
            case .failure(let error):
                handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Dictionary.DownloadImages.Response(result: .failure(ModelDictionaryError.serverCommandError(error: error))))
            }
        }
    }
    
    func dictionaryAnywayFirstOperator(with code: QRCode, mapping: QRMapping) -> OperatorGroupData.OperatorData? {
        
        guard let inn = code.stringValue(type: .general(.inn), mapping: mapping) else { return nil }
        
        return dictionaryAnywayOperators()?.first(where: { $0.synonymList.contains(inn) })
    }
    
    func dictionaryAnywayOperators(with code: QRCode, mapping: QRMapping) -> [OperatorGroupData.OperatorData]? {
        
        guard let inn = code.stringValue(type: .general(.inn), mapping: mapping) else { return nil }
        
        return dictionaryAnywayOperators()?.filter( { $0.synonymList.contains(inn) }).filter({$0.parameterList.isEmpty == false})
    }
    
    func serviceName(
        for inn: String
    ) -> String? {
        
        guard let operators = dictionaryAnywayOperators(),
              let first = operators.first(where: { $0.synonymList.first == inn })
        else { return nil }
        
        return serviceName(for: first)
    }
    
    func serviceName(
        for `operator`: OperatorGroupData.OperatorData
    ) -> String? {
        
        guard let groups = dictionaryAnywayOperatorGroups(),
              let parent = groups.first(where: { $0.isGroup && $0.code == `operator`.parentCode })
        else { return nil }
        
        return parent.name
    }
}

// MARK: - Helper

private extension ModelAction.Dictionary.DownloadImages.Request {
    
    // TODO: temp solution
    // should implement HTTPClient blacklisting in the Composition Root
    /// Returns an optional instance of `Request` with placeholder and empty image IDs removed.
    ///
    /// If the initial list of image IDs is empty or all IDs are placeholders or empty, the method returns `nil`.
    ///
    /// - Returns: An optional `Request` instance with cleaned image IDs, or `nil` if the initial list is empty or all IDs were placeholders or empty.
    func cleaned() -> Self? {
        
        let filtered = imagesIds.filter { !$0.isEmpty && $0 != "placeholder" && $0 != "sms" }
        return filtered.isEmpty ? nil : .init(imagesIds: filtered)
    }
}

// MARK: - Error

enum ModelDictionaryError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
}

// MARK: - typealias

extension Model {
    
    typealias ServerCommandsGetBannerCatalogList = ServerCommands.DictionaryController.GetBannerCatalogList
}
