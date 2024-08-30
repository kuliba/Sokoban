//
//  ProductsData+hasCorporateCardsOnly.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

extension ProductsData {
    
    var hasCorporateCardsOnly: Bool {
        
        let productsTypes: [ProductType] = keys.map { $0 }
        
        guard productsTypes == [.card] ||
                (productsTypes.onlyCardsWithDeposits &&
                 !hasDemandDepositWithAllowDebit)
        else { return false }
        
        guard Set(cardsTypes).contains(where: { $0.isCorporateCard })
        else { return false }
        
        return Set(cardsStatus).isDisjoint(with: .individualActiveCards)
    }
    
    var hasDemandDepositWithAllowDebit: Bool {
        
        let demandDepositsWithAllowDebit = products(.deposit)
            .filter {
                
                guard let deposit = $0.asDeposit,
                      deposit.isDemandDeposit,
                      deposit.allowDebit
                else { return false }
                
                return true
            }
        
        return demandDepositsWithAllowDebit.count > 0
    }
    
    var cardsTypes: [ProductCardData.CardType] {
        
        products(.card).compactMap(\.asCard?.cardType).uniqued()
    }
    
    var cardsStatus: [CardInfo] {
        
        return products(.card).compactMap{
            
            guard let cardType = $0.asCard?.cardType,
                    let status = $0.asCard?.statusCard
            else { return nil }
            
            return .init(type: cardType, status: status)
        }.uniqued()
    }
    
    struct CardInfo: Hashable {
        
        let type: ProductCardData.CardType
        let status: ProductCardData.StatusCard
    }
    
    func products(
        _ productType: ProductType
    ) -> [ProductData] {
        
        self[productType] ?? []
    }
}

extension Set where Element == ProductsData.CardInfo {
    
    static let individualActiveCards: Self = [
        .init(type: .main, status: .active),
        .init(type: .regular, status: .active),
        .init(type: .additionalSelf, status: .active),
        .init(type: .additionalOther, status: .active),
        .init(type: .additionalSelfAccOwn, status: .active)
    ]
}
