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
        
        mutating func remove<T: ProductDataFilterRule>(ruleType: T.Type) {

            rules = rules.filter({ type(of: $0) != ruleType })
        }
        
        mutating func replace<T: ProductDataFilterRule>(with rule: T) {
            
            remove(ruleType: type(of: rule))
            rules.append(rule)
        }
    }
}


//MARK: - ProductType Rules

extension ProductData.Filter {
    
    struct ProductTypeRule: ProductDataFilterRule {
        
        let allowed: Set<ProductType>
        
        init(_ allowed: Set<ProductType>) {
            
            self.allowed = allowed
        }
        
        func result(_ productData: ProductData) -> Bool? {
            
            allowed.contains(productData.productType)
        }
    }
}

//MARK: - Product Rules

extension ProductData.Filter {
    
    struct CurrencyRule: ProductDataFilterRule {
        
        let allowed: Set<Currency>
        
        init(_ allowed: Set<Currency>) {
            
            self.allowed = allowed
        }
        
        func result(_ productData: ProductData) -> Bool? {
            
            allowed.map({ $0.description }).contains(productData.currency)
        }
    }
    
    struct DebitRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            productData.allowDebit == true
        }
    }
    
    struct CreditRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            productData.allowCredit == true
        }
    }
    
    struct ProductRestrictedRule: ProductDataFilterRule {
        
        let restricted: Set<ProductData.ID>
        
        init(_ restricted: Set<ProductData.ID>) {
            
            self.restricted = restricted
        }
        
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
    
    
    struct CardAdditionalNotOwnedRetrictedRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }
            
            // check if this is additional product
            guard productCard.isMain == false else {
                return nil
            }
            
            return productCard.isProductOwner == true
        }
    }
    
    struct CardAdditionalOwnedRetrictedRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }
            
            // check if this is additional product
            guard productCard.isMain == false else {
                return nil
            }
            
            return productCard.isProductOwner == false
        }
    }
}
    
//MARK: - Account Rules

extension ProductData.Filter {
    
    struct AccountActiveRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productAccount = productData as? ProductAccountData else {
                return nil
            }
            
            return productAccount.status == .notBlocked
        }
    }
}

//MARK: - Deposit Rules

extension ProductData.Filter {
    
    struct DemandDepositRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productDeposit = productData as? ProductDepositData else {
                return nil
            }
            
            return productDeposit.isDemandDepositProduct
        }
    }
}
//MARK: - Presets

extension ProductData.Filter  {
    
    //MARK: General Payment Filter
    
    static let generalFrom = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account]),
                CurrencyRule([.rub]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])
    
    static let generalTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account]),
                CurrencyRule([.rub]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])
    
    static let generalFromWithDeposit = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule(),
                DemandDepositRule()])
    
    static let generalToWithDeposit = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule(),
                DemandDepositRule()])
    
    //MARK: Me2Me Payment Filter
    
    static let meToMeFrom = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])
    
    static let meToMeTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])

    //MARK: Close Account Base
    
    static let closeAccountFrom = ProductData.Filter(
        rules: [AllRestrictedRule()])
    
    // add in code
    // CurrencyRule([productFrom.currency]
    // ProductRestrictedRule([productFrom.id])
    static let closeAccountTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])
    
    
    //MARK: Close Deposit
    
    static let closeDepositFrom = ProductData.Filter(
        rules: [AllRestrictedRule()])
    
    // add in code
    // CurrencyRule([productFrom.currency]
    // ProductRestrictedRule([productFrom.id])
    static let closeDepositTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardAdditionalNotOwnedRetrictedRule(),
                AccountActiveRule()])
}
