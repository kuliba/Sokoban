//
//  RootViewModelFactory+composedLoadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

import VortexTools
extension RootViewModelFactory {
    
    func composedLoadOperators(
        categoryType: ServiceCategory.CategoryType,
        completion: @escaping ([UtilityPaymentProvider]) -> Void
    ) {
        composedLoadOperators(payload: .init(categoryType: categoryType, pageSize: settings.pageSize), completion: completion)
    }
    
    func composedLoadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([UtilityPaymentProvider]) -> Void
    ) {
        schedulers.userInitiated.schedule { [weak self] in
            
            guard let self else { return }
            
            // sorting is performed at cache phase
            let page = loadPage(of: [CodableServicePaymentOperator].self, for: payload) ?? []
            completion(page.map(UtilityPaymentProvider.init(codable:)))
        }
    }
}

// MARK: - Load Operators

struct LoadOperatorsPayload: Equatable {
    
    let categoryType: ServiceCategory.CategoryType
    let operatorID: String?
    let searchText: String
    let pageSize: Int
    
    init(
        categoryType: ServiceCategory.CategoryType,
        operatorID: String? = nil,
        searchText: String = "",
        pageSize: Int
    ) {
        self.categoryType = categoryType
        self.operatorID = operatorID
        self.searchText = searchText
        self.pageSize = pageSize
    }
}

// MARK: - Helpers

extension CodableServicePaymentOperator: FilterableItem {
    
    func matches(_ payload: LoadOperatorsPayload) -> Bool {
        
        categoryType == payload.categoryType && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

extension LoadOperatorsPayload: PageQuery {
    
    var id: String? { operatorID }
}

// MARK: - Adapters

private extension UtilityPaymentProvider {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            icon: codable.md5Hash,
            inn: codable.inn,
            title: codable.name,
            type: codable.type
        )
    }
}

extension UtilityPaymentProvider {
    
    var categoryType: ServiceCategory.CategoryType {
        
        return .init(string: type) ?? .housingAndCommunalService
    }
}

extension CodableServicePaymentOperator {
    
    var categoryType: ServiceCategory.CategoryType {
        
        return .init(string: type) ?? .housingAndCommunalService
    }
}

extension ServiceCategory.CategoryType {
    
    init?(string: String) {
        
        switch string {
        case "charity":
            self = .charity
        case "digitalWallets":
            self = .digitalWallets
        case "education":
            self = .education
        case "housingAndCommunalService":
            self = .housingAndCommunalService
        case "internet":
            self = .internet
        case "mobile":
            self = .mobile
        case "networkMarketing":
            self = .networkMarketing
        case "qr":
            self = .qr
        case "repaymentLoansAndAccounts":
            self = .repaymentLoansAndAccounts
        case "security":
            self = .security
        case "socialAndGames":
            self = .socialAndGames
        case "taxAndStateService":
            self = .taxAndStateService
        case "transport":
            self = .transport
        default:
            return nil
        }
    }
}
