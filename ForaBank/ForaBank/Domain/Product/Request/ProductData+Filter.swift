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
        
        func filteredProducts(_ products: [ProductData]) -> [ProductData] {
            
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
        
        func filteredProductsTypes(_ products: [ProductData]) -> [ProductType] {
            
            let filteredProducts = filteredProducts(products)
            let uniqueTypes = Set(filteredProducts.map({ $0.productType }))
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
    
    struct ProductActiveRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            switch productData {
            case let productCard as ProductCardData:
                return !productCard.isBlocked
                
            case let productAccount as ProductAccountData:
                return productAccount.status == .notBlocked
                
            default:
                return nil
            }
        }
    }
    
    struct CardActiveRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productCard = productData as? ProductCardData else {
                return nil
            }

            if productCard.loanBaseParam != nil {
                
                // credit card
                return productCard.status == .active && productCard.statusPc == .active
                
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
        
    struct CardAdditionalSelfRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let cardType = productData.asCard?.cardType else {
                return nil
            }
            
            switch cardType {
            case .additionalSelf, .additionalSelfAccOwn:
                return true
                
            case .additionalOther, .additionalCorporate:
                return false
                
            default:
                return nil
            }
        }
    }
    
    struct CardAdditionalSelfAccOwnRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let cardType = productData.asCard?.cardType else {
                return nil
            }
            
            switch cardType {
                
            case .additionalSelf, .additionalOther, .additionalCorporate:
                return false
                
            case .additionalSelfAccOwn:
                return true
                
            default:
                return nil
            }
        }
    }
    
    struct CardCorporateRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let cardType = productData.asCard?.cardType else {
                return nil
            }
            
            return !cardType.isCorporateCard 
        }
    }
    
    struct CardCorporateIsIndividualBusinessmanMainRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let cardType = productData.asCard?.cardType,
                    cardType.isCorporateCard else { return nil }
            
            return cardType == .individualBusinessmanMain
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
    
    struct RestrictedDepositRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
                    
          return productData as? ProductDepositData == nil
        }
    }
    
    struct DemandDepositRule: ProductDataFilterRule {
        
        func result(_ productData: ProductData) -> Bool? {
            
            guard let productDeposit = productData as? ProductDepositData else {
                return nil
            }
            
            return productDeposit.isDemandDeposit
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
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    static let generalFromWithIndividualBusinessmanMain = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account]),
                CurrencyRule([.rub]),
                CardActiveRule(),
                CardCorporateIsIndividualBusinessmanMainRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    static let generalTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account]),
                CurrencyRule([.rub]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    // TODO: преобразовать filter в Data Type и добавить тесты
    
    static let generalToWithDeposit = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    static let generalToWithDepositAndIndividualBusinessmanMain = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardCorporateIsIndividualBusinessmanMainRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    //MARK: Currency Wallet
    
    static let currencyWalletFrom = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule(),
                DemandDepositRule()])
    
    static let currencyWalletTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account, .deposit]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule(),
                DemandDepositRule()])
    
    //MARK: Me2Me Payment Filter
    
    static let meToMeFrom = ProductData.Filter(
        rules: [DebitRule(),
                ProductTypeRule([.card, .account]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    static let meToMeTo = ProductData.Filter(
        rules: [CreditRule(),
                ProductTypeRule([.card, .account]),
                CardActiveRule(),
                CardCorporateRule(),
                CardAdditionalSelfRule(),
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
                CardCorporateIsIndividualBusinessmanMainRule(),
                CardAdditionalSelfRule(),
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
                CardCorporateIsIndividualBusinessmanMainRule(),
                CardAdditionalSelfRule(),
                AccountActiveRule()])
    
    static func c2bFilter(
        productTypes: [ProductType],
        currencies: [Currency],
        additional: Bool
    ) -> ProductData.Filter {
        
        var rules = [ProductDataFilterRule]()

        rules.append(ProductData.Filter.ProductTypeRule(Set(productTypes)))
        rules.append(ProductData.Filter.CurrencyRule(Set(currencies)))
        
        if additional == false {
            
            rules.append(ProductData.Filter.CardAdditionalSelfAccOwnRule())
            rules.append(ProductData.Filter.CardAdditionalSelfRule())
        }
        
        rules.append(ProductData.Filter.ProductActiveRule())
        
        return .init(rules: rules)
    }
}
