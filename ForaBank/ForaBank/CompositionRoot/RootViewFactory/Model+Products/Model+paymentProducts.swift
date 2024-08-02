//
//  Model+paymentProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

extension Model {
    
    func paymentProducts() -> [ProductData] {
        
        // TODO: fix filtering according to https://shorturl.at/hIE5B
        allProducts
            .filter(\.allowDebit)
            .filter(\.isActive)
            .filter(\.isMainProduct)
    }
}

extension Model {
    
    func paymentEligibleProducts() -> [ProductData] {
        
        allProducts
            .filter(\.allowDebit)
            .filter(\.isActive)
            .filter(\.isPaymentEligible)
    }
}

private extension ProductData {
    
    var isActive: Bool {
        
        if let card = self as? ProductCardData {
            
            return card.statusPc == .active
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
    
    var isMainProduct: Bool {
        
        if let card = self as? ProductCardData,
           let isMain = card.isMain {
            
            return isMain
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
    
    var isMainOrAdditionalSelfAccOwnProduct: Bool {
        
        if let card = self as? ProductCardData, let cardType = card.cardType {
            
            return cardType.isMainOrRegularOrAdditionalSelfAccOwn
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
    
    var isPaymentEligible: Bool {
        
        if let card = self as? ProductCardData,
           let cardType = card.cardType {
            
            return cardType.isPaymentEligible
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
}

extension ProductCardData.CardType {
    
    var isPaymentEligible: Bool {
        
        return self == .regular ||
        self == .main ||
        self == .additionalSelf ||
        self == .additionalSelfAccOwn
    }
}
