//
//  ProductData+Filter.swift
//  ForaBank
//
//  Created by Max Gribov on 22.11.2022.
//

import Foundation

protocol ProductDataFilterRule {
    
    func result(_ productData: ProductData) -> Bool?
}

extension ProductData {
    
    struct Filter {
        
        var rules: [ProductDataFilterRule]
        
        //TODO: Tests
        func filterredProducts(_ products: [ProductData]) -> [ProductData] {
            
            products.filter { productData in
                
                var result = true
                
                for rule in rules {
                    
                    guard let ruleResult = rule.result(productData) else {
                        continue
                    }
                    
                    result = result && ruleResult
                }
                
                return result
            }
        }
        
        func filterredProductsTypes(_ products: [ProductData]) -> [ProductType] {
            
            let filterredProducts = filterredProducts(products)
            let uniqueTypes = Set(filterredProducts.map({ $0.productType }))
            let sortedTypes = Array(uniqueTypes).sorted(by: { $0.order < $1.order })
            
            return sortedTypes
        }
    }
}


//MARK: - ProductType Rules

extension ProductData.Filter {
    
    struct ProductTypeAllowedRule: ProductDataFilterRule {
        
        let allowed: Set<ProductType>
        
        func result(_ productData: ProductData) -> Bool? {
            
            allowed.contains(productData.productType)
        }
    }
}

//MARK: - Product Rules

extension ProductData.Filter {
    
    struct CurrencyAllowedRule: ProductDataFilterRule {
        
        let allowed: Set<Currency>
        
        func result(_ productData: ProductData) -> Bool? {
            
            allowed.map({ $0.description }).contains(productData.currency)
        }
    }
    
    struct FromRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            productData.allowDebit == true
        }
    }
    
    struct ToRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            productData.allowCredit == true
        }
    }
    
    struct ProductRestrictedRule: ProductDataFilterRule {
        
        let restricted: Set<ProductData.ID>
        
        func result(_ productData: ProductData) -> Bool? {
            
            restricted.contains(productData.id) == false
        }
    }
    
    struct AllRestrictedRule: ProductDataFilterRule {

        func result(_ productData: ProductData) -> Bool? {
            
            false
        }
    }
}

//MARK: - Card Rules

extension ProductData.Filter {
    
    struct CardActiveRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }

            if let loanBaseParam = productCard.loanBaseParam {
                
                // loan card
                return productCard.status == .active && productCard.statusPc == .active && loanBaseParam.clientId == productCard.ownerId
                
            } else {
               
                // regular card
                return productCard.status == .active && productCard.statusPc == .active
            }
        }
    }
    
    struct CardLoanRestrictedRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }
            
            return productCard.loanBaseParam == nil
        }
    }
    
    struct CardAdditionalRetrictedRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }
            
            return productCard.isMain == true
        }
    }
}
    
//MARK: - Account Rules

extension ProductData.Filter {
    
    struct AccountNotBlockedRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productAccount = productData as? ProductAccountData else {
                return nil
            }
            
            return productAccount.status == .notBlocked
        }
    }
}

//MARK: - Presets

extension ProductData.Filter  {
    
    static let generalFrom = ProductData.Filter(
        rules: [FromRule(),
                ProductTypeAllowedRule(allowed: [.card, .account]),
                CurrencyAllowedRule(allowed: [.rub]),
                CardActiveRule(),
                AccountNotBlockedRule()])
    
    static let generalTo = ProductData.Filter(
        rules: [ToRule(),
                ProductTypeAllowedRule(allowed: [.card, .account]),
                CurrencyAllowedRule(allowed: [.rub]),
                CardActiveRule(),
                AccountNotBlockedRule()])
    

    //MARK: Close Account
    
    static let closeAccountFrom = ProductData.Filter(
        rules: [AllRestrictedRule()])
    
    static let closeAccountTo = ProductData.Filter(
        rules: [ToRule(),
                ProductTypeAllowedRule(allowed: [.card, .account]),
                CardActiveRule(),
                AccountNotBlockedRule()])
    
    //MARK: Close Deposit
    
    static let closeDepositFrom = ProductData.Filter(
        rules: [AllRestrictedRule()])
    
    static let closeDepositTo = ProductData.Filter(
        rules: [ToRule(),
                ProductTypeAllowedRule(allowed: [.card, .account]),
                CardActiveRule(),
                AccountNotBlockedRule()])
}
