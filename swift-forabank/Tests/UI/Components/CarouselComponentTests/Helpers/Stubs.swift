//
//  Stubs.swift
//
//
//  Created by Disman Dmitry on 27.02.2024.
//

import CarouselComponent

typealias ProductSeparators = [CarouselProduct.ProductType: [CarouselProduct]]

extension Array where Element == CarouselProduct {
    
    static let empty: Self = []
    
    static let cards: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn,
        .cardRegular, .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3
    ]
        
    static let moreProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4,
        .cardAdditionalOther4, .cardAdditionalOther5, .cardAdditionalSelf3, .cardAdditionalSelfAccOwn2,
        .cardRegular2, .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7
    ]
        
    static let nonCardProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4
    ]
    
    static let mainWithAdditionalCards: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
    ]
    
    static let regularWithAdditionalCards: Self = [
        .cardRegular, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
    ]
    
    static let additionalCards: Self = [
        .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
    ]
    
    static let allCardProducts: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn,
        .cardRegular, .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3,
        .cardAdditionalOther4, .cardAdditionalOther5, .cardAdditionalSelf3, .cardAdditionalSelfAccOwn2,
        .cardRegular2, .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7
    ]
    
    static let allCardProductsWithSticker: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn,
        .cardRegular, .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3,
        .cardAdditionalOther4, .cardAdditionalOther5, .cardAdditionalSelf3, .cardAdditionalSelfAccOwn2,
        .cardRegular2, .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7, .sticker
    ]
    
    static let accountProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4
    ]
    
    static let depositProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4
    ]
    
    static let loanProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4
    ]
    
    static let threeCards: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf
    ]
}

extension CarouselProduct {
    
    private init(
        id: Int,
        _ type: ProductType,
        _ cardType: CardType? = nil
    ) {
        self.init(id: .init(id), type: type, cardType: cardType)
    }
        
    static let card: Self = .init(id: 1, .card, .main)
    static let cardAdditionalOther: Self = .init(id: 2, .card, .additionalOther)
    static let cardAdditionalSelf: Self = .init(id: 3, .card, .additionalSelf)
    static let cardAdditionalSelfAccOwn: Self = .init(id: 4, .card, .additionalSelfAccOwn)
    static let cardRegular: Self = .init(id: 5, .card, .regular)
    static let cardAdditionalOther2: Self = .init(id: 6, .card, .additionalOther)
    static let cardAdditionalSelf2: Self = .init(id: 7, .card, .additionalSelf)
    static let cardAdditionalOther3: Self = .init(id: 8, .card, .additionalOther)
    
    static let account1: Self = .init(id: 9, .account, nil)
    static let deposit1: Self = .init(id: 10, .deposit, nil)
    static let loan1: Self = .init(id: 11, .loan, nil)
    static let account2: Self = .init(id: 12, .account, nil)
    static let account3: Self = .init(id: 13, .account, nil)
    static let loan2: Self = .init(id: 14, .loan, nil)
    static let deposit2: Self = .init(id: 15, .deposit, nil)
    static let account4: Self = .init(id: 16, .account, nil)
    
    static let cardAdditionalOther4: Self = .init(id: 17, .card, .additionalOther)
    static let cardAdditionalOther5: Self = .init(id: 18, .card, .additionalOther)
    static let cardAdditionalSelf3: Self = .init(id: 19, .card, .additionalSelf)
    static let cardAdditionalSelfAccOwn2: Self = .init(id: 20, .card, .additionalSelfAccOwn)
    static let cardRegular2: Self = .init(id: 21, .card, .regular)
    static let cardAdditionalOther6: Self = .init(id: 22, .card, .additionalOther)
    static let cardAdditionalSelf4: Self = .init(id: 23, .card, .additionalSelf)
    static let cardAdditionalOther7: Self = .init(id: 24, .card, .additionalOther)
    
    static let sticker: Self = .init(id: 25, .card, .sticker)
}

extension Array where Element == ProductGroup {
    
    static let cards: Self = [
        .init(productType: .card, products: .cards)
    ]
        
    static let moreProducts: Self = [
        
        .init(productType: .card, products: [
            .cardAdditionalOther4,.cardAdditionalOther5, .cardAdditionalSelf3,
            .cardAdditionalSelfAccOwn2, .cardRegular2, .cardAdditionalOther6,
            .cardAdditionalSelf4, .cardAdditionalOther7
        ]),
        .init(productType: .account, products: [.account1, .account2, .account3, .account4]),
        .init(productType: .deposit, products: [.deposit1, .deposit2]),
        .init(productType: .loan, products: [.loan1, .loan2])
    ]
        
    static let nonCardProducts: Self = [
        
        .init(productType: .account, products: [.account1, .account2, .account3, .account4]),
        .init(productType: .deposit, products: [.deposit1, .deposit2]),
        .init(productType: .loan, products: [.loan1, .loan2])
    ]
    
    static let mainWithAdditionalCards: Self = [
        
        .init(productType: .card, products: [
            .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
    
    static let regularWithAdditionalCards: Self = [
        
        .init(productType: .card, products: [
            .cardRegular, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
    
    static let additionalCards: Self = [
        
        .init(productType: .card, products: [
            .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
}

extension ProductSeparators {
    
    static let emptySeparators: Self = [:]
    
    static let separatorsForPreviewProducts: Self = [.card: [
        .cardAdditionalSelfAccOwn, .cardRegular]
    ]
        
    static let separatorsForMoreProducts: Self = [.card: [
        .cardAdditionalSelfAccOwn2, .cardRegular2]
    ]
}

extension ProductGroup {
    
    static let cards: Self = .init(productType: .card, products: .cards)
    static let allCardProducts: Self = .init(productType: .card, products: .allCardProducts)
    static let allCardProductsWithSticker: Self = .init(productType: .card, products: .allCardProductsWithSticker)
    static let accountProducts: Self = .init(productType: .account, products: .accountProducts)
    static let depositProducts: Self = .init(productType: .deposit, products: .depositProducts)
    static let loanProducts: Self = .init(productType: .loan, products: .loanProducts)
    static let threeCards: Self = .init(productType: .card, products: .threeCards)
}

extension String {
    
    static let spoilerTitleForCardProducts: Self = .init("+5")
    static let spoilerTitleForAllCardProducts: Self = .init("+13")
    static let spoilerTitleForAllCardProductsWithSticker: Self = .init("+14")
}
