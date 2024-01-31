//
//  ResponseMapper+mapGetProductDynamicParamsList.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public extension ResponseMapper {
    
    typealias GetProductDynamicParamsListResult = Result<DynamicParamsList, MappingError>
    
    static func mapGetProductDynamicParamsList(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> GetProductDynamicParamsListResult {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> DynamicParamsList {
        return .init(list: data.dynamicProductParamsList.map { .init(data: $0) })
    }
}

private extension ResponseMapper {
    
    typealias _Data = _DTO
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        let dynamicProductParamsList: [ItemDecodable]
        
        enum CodingKeys: String, CodingKey {
            case dynamicProductParamsList
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dynamicProductParamsList = try container.decode([ItemDecodable].self, forKey: .dynamicProductParamsList)
        }
    }
}

private extension ResponseMapper {
    
    struct ItemDecodable: Decodable {
        
        let productId: Int
        let type: ProductTypeDecodable
        let dynamicParams: VariableParamsDecodable
        
        enum CodingKeys: String, CodingKey {
            case productId = "id"
            case type, dynamicParams
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            productId = try container.decode(Int.self, forKey: .productId)
            type = try container.decode(ProductTypeDecodable.self, forKey: .type)

            switch type {
            case .card:
                let cardParams = try container.decode( ResponseMapper.ItemDecodable.CardParamsDecodable.self, forKey: .dynamicParams)

                dynamicParams = .card(cardParams)

            case .account:
                let accountParams = try container.decode(ResponseMapper.ItemDecodable.AccountParamsDecodable.self, forKey: .dynamicParams)
                dynamicParams = .account(accountParams)

            case .deposit, .loan:
                let productParams = try container.decode(ResponseMapper.ItemDecodable.DepositOrLoanParamsDecodable.self, forKey: .dynamicParams)
                dynamicParams = .depositOrLoan(productParams)
            }
        }
    }
}

private extension ResponseMapper {
    
    enum ProductTypeDecodable: String, Decodable {
        
        case account = "ACCOUNT"
        case card = "CARD"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }
}

private extension ResponseMapper.ItemDecodable {
    
    enum VariableParamsDecodable: Decodable {
        case account(AccountParamsDecodable)
        case card(CardParamsDecodable)
        case depositOrLoan(DepositOrLoanParamsDecodable)
    }
}

private extension ResponseMapper.ItemDecodable {
    
    struct AccountParamsDecodable: Decodable {
        
        let status: String
        let balance: Decimal?
        let balanceRub: Decimal?
        let customName: String?
        
        enum CodingKeys: String, CodingKey {
            case balanceRub = "balanceRUB"
            case balance, customName, status
        }
    }
}

private extension ResponseMapper.ItemDecodable {
    
    struct CardParamsDecodable: Decodable {
        
        let balance: Decimal?
        let balanceRub: Decimal?
        let customName: String?
        let availableExceedLimit: Decimal?
        let status: String
        let debtAmount: Decimal?
        let totalDebtAmount: Decimal?
        let statusPc: String
        let statusCard: StatusCardDecodable
        
        enum CodingKeys: String, CodingKey {
            case balanceRub = "balanceRUB"
            case balance, availableExceedLimit
            case status, statusCard, customName
            case debtAmount, totalDebtAmount
            case statusPc = "statusPC"
        }
    }
}

private extension ResponseMapper.ItemDecodable {
    
    struct DepositOrLoanParamsDecodable: Decodable {
        
        let balance: Decimal?
        let balanceRub: Decimal?
        let customName: String?
        
        enum CodingKeys: String, CodingKey {
            case balanceRub = "balanceRUB"
            case balance, customName
        }
    }
}

private extension ResponseMapper.ItemDecodable.CardParamsDecodable {
    
    enum StatusCardDecodable: String, Decodable {
        
        case active = "ACTIVE"
        case blockedUlockAvailable = "BLOCKED_UNLOCK_AVAILABLE"
        case blockedUlockNotAvailable = "BLOCKED_UNLOCK_NOT_AVAILABLE"
        case notActivated = "NOT_ACTIVE"
    }
}

private extension DynamicParamsItem {
    
    init(
        data: ResponseMapper.ItemDecodable
    ) {
        self = .init(id: data.productId, type: data.type.value, dynamicParams: .init(data: data))
    }
}

private extension ResponseMapper.ProductTypeDecodable {
    
    var value: DynamicParamsItem.ProductType {
        
        switch self {
            
        case .account:
            return .account
        case .card:
            return .card
        case .deposit:
            return .deposit
        case .loan:
            return .loan
        }
    }
}

private extension DynamicParams {
    
    init(
        data: ResponseMapper.ItemDecodable
    ) {
        
        switch data.dynamicParams {
            
        case let .account(value):
            self = .init(variableParams: .account(.init(data: value)))
        case let .card(value):
            self = .init(variableParams: .card(.init(data: value)))
        case let .depositOrLoan(value):
            self = .init(variableParams: .depositOrLoan(.init(data: value)))
        }
    }
}

private extension AccountDynamicParams {
    
    init(
        data: ResponseMapper.ItemDecodable.AccountParamsDecodable
    ) {
        
        self = .init(status: data.status, balance: data.balance, balanceRub: data.balanceRub, customName: data.customName)
    }
}

private extension CardDynamicParams {
    
    init(
        data: ResponseMapper.ItemDecodable.CardParamsDecodable
    ) {
        
        self = .init(balance: data.balance, balanceRub: data.balanceRub, customName: data.customName, availableExceedLimit: data.availableExceedLimit, status: data.status, debtAmount: data.debtAmount, totalDebtAmount: data.totalDebtAmount, statusPc: data.statusPc, statusCard: data.statusCard.value)
    }
}

private extension ResponseMapper.ItemDecodable.CardParamsDecodable.StatusCardDecodable {
    
    var value: CardDynamicParams.StatusCard {
        
        switch self {
            
        case .active:
            return .active
        case .blockedUlockAvailable:
            return .blockedUlockAvailable
        case .blockedUlockNotAvailable:
            return .blockedUlockNotAvailable
        case .notActivated:
            return .notActivated
        }
    }
}

private extension DepositOrLoanDynamicParams {
    
    init(
        data: ResponseMapper.ItemDecodable.DepositOrLoanParamsDecodable
    ) {
        
        self = .init(balance: data.balance, balanceRub: data.balanceRub, customName: data.customName)
    }
}
