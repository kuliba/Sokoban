//
//  Stubs.swift
//
//
//  Created by Disman Dmitry on 27.02.2024.
//

import CarouselComponent

typealias ProductSeparators = [Product.ID.ProductType: [Product.ID]]

extension Array where Element == Product {
    
    static let empty: Self = []
    
    static let cards: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn,
        .cardRegular, .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3
    ]
    
    static let cardsWithSticker: Self = [
        .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn,
        .cardRegular, .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3, .sticker
    ]
    
    static let moreProducts: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4,
        .cardAdditionalOther4, .cardAdditionalOther5, .cardAdditionalSelf3, .cardAdditionalSelfAccOwn2,
        .cardRegular2, .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7
    ]
    
    static let moreProductsWithSticker: Self = [
        .account1, .deposit1, .loan1, .account2, .account3, .loan2, .deposit2, .account4,
        .cardAdditionalOther4, .cardAdditionalOther5, .cardAdditionalSelf3, .cardAdditionalSelfAccOwn2,
        .cardRegular2, .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7, .sticker
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

extension Product {
    
    private init(
        id: Int,
        _ type: ID.ProductType,
        _ cardType: ID.CardType? = nil,
        _ order: Int
    ) {
        self.init(
            id: .init(value: .init(id), type: type, cardType: cardType),
            order: order
        )
    }
        
    static let card: Self = .init(id: 1, .card, .main, 0)
    static let cardAdditionalOther: Self = .init(id: 2, .card, .additionalOther, 1)
    static let cardAdditionalSelf: Self = .init(id: 3, .card, .additionalSelf, 2)
    static let cardAdditionalSelfAccOwn: Self = .init(id: 4, .card, .additionalSelfAccOwn, 3)
    static let cardRegular: Self = .init(id: 5, .card, .regular, 4)
    static let cardAdditionalOther2: Self = .init(id: 6, .card, .additionalOther, 5)
    static let cardAdditionalSelf2: Self = .init(id: 7, .card, .additionalSelf, 6)
    static let cardAdditionalOther3: Self = .init(id: 8, .card, .additionalOther, 7)
    
    static let account1: Self = .init(id: 9, .account, nil, 0)
    static let deposit1: Self = .init(id: 10, .deposit, nil, 0)
    static let loan1: Self = .init(id: 11, .loan, nil, 0)
    static let account2: Self = .init(id: 12, .account, nil, 0)
    static let account3: Self = .init(id: 13, .account, nil, 0)
    static let loan2: Self = .init(id: 14, .loan, nil, 0)
    static let deposit2: Self = .init(id: 15, .deposit, nil, 0)
    static let account4: Self = .init(id: 16, .account, nil, 0)
    
    static let cardAdditionalOther4: Self = .init(id: 17, .card, .additionalOther, 8)
    static let cardAdditionalOther5: Self = .init(id: 18, .card, .additionalOther, 9)
    static let cardAdditionalSelf3: Self = .init(id: 19, .card, .additionalSelf, 10)
    static let cardAdditionalSelfAccOwn2: Self = .init(id: 20, .card, .additionalSelfAccOwn, 11)
    static let cardRegular2: Self = .init(id: 21, .card, .regular, 12)
    static let cardAdditionalOther6: Self = .init(id: 22, .card, .additionalOther, 13)
    static let cardAdditionalSelf4: Self = .init(id: 23, .card, .additionalSelf, 14)
    static let cardAdditionalOther7: Self = .init(id: 24, .card, .additionalOther, 15)
    
    static let sticker: Self = .init(id: 25, .card, .sticker, 16)
}

extension Array where Element == ProductGroup {
    
    static let cards: Self = [
        .init(id: .card, products: .cards)
    ]
    
    static let cardsWithSticker: Self = [
        .init(id: .card, products: .cardsWithSticker)
    ]
    
    static let moreProducts: Self = [
        
        .init(id: .card, products: [
            .cardAdditionalOther4,.cardAdditionalOther5, .cardAdditionalSelf3,
            .cardAdditionalSelfAccOwn2, .cardRegular2, .cardAdditionalOther6,
            .cardAdditionalSelf4, .cardAdditionalOther7
        ]),
        .init(id: .account, products: [.account1, .account2, .account3, .account4]),
        .init(id: .deposit, products: [.deposit1, .deposit2]),
        .init(id: .loan, products: [.loan1, .loan2])
    ]
    
    static let allProducts: Self = [
        
        .init(id: .card, products: [
            .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn, .cardRegular,
            .cardAdditionalOther2, .cardAdditionalSelf2, .cardAdditionalOther3, .cardAdditionalOther4,
            .cardAdditionalOther5, .cardAdditionalSelf3,.cardAdditionalSelfAccOwn2, .cardRegular2,
            .cardAdditionalOther6, .cardAdditionalSelf4, .cardAdditionalOther7
        ]),
        .init(id: .account, products: [.account1, .account2, .account3, .account4]),
        .init(id: .deposit, products: [.deposit1, .deposit2]),
        .init(id: .loan, products: [.loan1, .loan2])
    ]
    
    static let nonCardProducts: Self = [
        
        .init(id: .account, products: [.account1, .account2, .account3, .account4]),
        .init(id: .deposit, products: [.deposit1, .deposit2]),
        .init(id: .loan, products: [.loan1, .loan2])
    ]
    
    static let mainWithAdditionalCards: Self = [
        
        .init(id: .card, products: [
            .card, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
    
    static let regularWithAdditionalCards: Self = [
        
        .init(id: .card, products: [
            .cardRegular, .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
    
    static let additionalCards: Self = [
        
        .init(id: .card, products: [
            .cardAdditionalOther, .cardAdditionalSelf, .cardAdditionalSelfAccOwn
        ])
    ]
}

extension ProductSeparators {
    
    static let emptySeparators: Self = [:]
    
    static let separatorsForPreviewProducts: Self = [.card: [
        Product.cardAdditionalSelfAccOwn.id, Product.cardRegular.id]
    ]
    
    static let separatorsForPreviewProductsWithSticker: Self = [.card: [
        Product.cardAdditionalSelfAccOwn.id, Product.cardRegular.id, Product.cardAdditionalOther3.id]
    ]
    
    static let separatorsForMoreProducts: Self = [.card: [
        Product.cardAdditionalSelfAccOwn2.id, Product.cardRegular2.id ]
    ]
    
    static let separatorsForAllProducts: Self = [.card: [
        Product.cardAdditionalSelfAccOwn.id, Product.cardRegular.id,
        Product.cardAdditionalSelfAccOwn2.id, Product.cardRegular2.id ]
    ]
}

extension ProductGroup {
    
    static let cards: Self = .init(id: .card, products: .cards)
    static let allCardProducts: Self = .init(id: .card, products: .allCardProducts)
    static let allCardProductsWithSticker: Self = .init(id: .card, products: .allCardProductsWithSticker)
    static let accountProducts: Self = .init(id: .account, products: .accountProducts)
    static let depositProducts: Self = .init(id: .deposit, products: .depositProducts)
    static let loanProducts: Self = .init(id: .loan, products: .loanProducts)
    static let threeCards: Self = .init(id: .card, products: .threeCards)
}

extension String {
    
    static let spoilerTitleForCardProducts: Self = .init("+5")
    static let spoilerTitleForAllCardProducts: Self = .init("+13")
    static let spoilerTitleForAllCardProductsWithSticker: Self = .init("+14")
}
