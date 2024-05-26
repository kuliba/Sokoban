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
}
