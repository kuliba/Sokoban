//
//  Model+paymentProducts.swift
//  Vortex
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
    
    @inlinable
    func paymentEligibleProducts() -> [ProductData] {
        
        allProducts
            .filter(\.isRub)
            .filter(\.allowDebit)
            .filter(\.isActive)
            .filter(\.isPaymentEligible)
    }
    
    @inlinable
    func c2gPaymentEligibleProducts() -> [ProductData] {
        
        allProducts
            .filter(\.isRub)
            .filter(\.allowDebit)
            .filter(\.isActive)
            .filter(\.isC2GPaymentEligible)
    }
}

extension ProductData {
    
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
            
            return cardType.isPaymentEligible && card.isActivated
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
    
    var isC2GPaymentEligible: Bool {
        
        if let card = self as? ProductCardData,
           let cardType = card.cardType {
            
            return cardType.isC2GPaymentEligible && card.isActivated
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
    
    var isRub: Bool {
        
        return currency == "RUB"
    }
}

extension ProductCardData.CardType {
    
    var isPaymentEligible: Bool {
        
        return self == .regular ||
        self == .main ||
        self == .additionalSelf ||
        self == .additionalSelfAccOwn
    }
    
    var isC2GPaymentEligible: Bool {
        
        [.regular, .main, .additionalSelfAccOwn].contains(self)
    }
}
