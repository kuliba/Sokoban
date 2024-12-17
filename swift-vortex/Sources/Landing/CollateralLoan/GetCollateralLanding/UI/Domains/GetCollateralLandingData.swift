//
//  GetCollateralLandingData.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

public struct GetCollateralLandingProduct: Equatable {
    
    public let theme: Theme
    public let name: String
    public let marketing: Marketing
    public let conditions: [Condition]
    public let calc: Calc
    public let frequentlyAskedQuestions: [FrequentlyAskedQuestion]
    public let documents: [Document]
    public let consents: [Consent]
    public let cities: [String]
    public let icons: Icons
    
    public init(
        theme: Theme,
        name: String,
        marketing: Marketing,
        conditions: [Condition],
        calc: Calc,
        frequentlyAskedQuestions: [FrequentlyAskedQuestion],
        documents: [Document],
        consents: [Consent],
        cities: [String],
        icons: Icons
    ) {
        self.theme = theme
        self.name = name
        self.marketing = marketing
        self.conditions = conditions
        self.calc = calc
        self.frequentlyAskedQuestions = frequentlyAskedQuestions
        self.documents = documents
        self.consents = consents
        self.cities = cities
        self.icons = icons
    }
    
    public enum Theme: String {
        
        case gray
        case white
        case unknown
    }
    
    public struct Marketing: Equatable {
        
        public let labelTag: String
        public let image: String
        public let params: [String]
        
        public init(
            labelTag: String,
            image: String,
            params: [String]
        ) {
            self.labelTag = labelTag
            self.image = image
            self.params = params
        }
    }
    
    public struct Condition: Equatable {
        
        public let icon: String
        public let title: String
        public let subTitle: String
        
        public init(icon: String, title: String, subTitle: String) {
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
        }
    }
    
    public struct Calc: Equatable {
        
        public let amount: Amount
        public let collateral: [Collateral]
        public let rates: [Rate]
        
        public init(amount: Amount, collateral: [Collateral], rates: [Rate]) {
            self.amount = amount
            self.collateral = collateral
            self.rates = rates
        }
        
        public struct Amount: Equatable {
            
            public let minIntValue: UInt
            public let maxIntValue: UInt
            public let maxStringValue: String
            
            public init(
                minIntValue: UInt,
                maxIntValue: UInt,
                maxStringValue: String
            ) {
                self.minIntValue = minIntValue
                self.maxIntValue = maxIntValue
                self.maxStringValue = maxStringValue
            }
        }
        
        public struct Collateral: Equatable {
            
            public let icon: String
            public let name: String
            public let type: String
            
            public init(icon: String, name: String, type: String) {
                
                self.icon = icon
                self.name = name
                self.type = type
            }
        }
        
        public struct Rate: Equatable {
            
            public let rateBase: Double
            public let ratePayrollClient: Double
            public let termMonth: UInt
            public let termStringValue: String
            
            public init(
                rateBase: Double,
                ratePayrollClient: Double,
                termMonth: UInt,
                termStringValue: String
            ) {
                self.rateBase = rateBase
                self.ratePayrollClient = ratePayrollClient
                self.termMonth = termMonth
                self.termStringValue = termStringValue
            }
        }
    }
    
    public struct FrequentlyAskedQuestion: Equatable {
        
        public let question: String
        public let answer: String
        
        public init(question: String, answer: String) {
            
            self.question = question
            self.answer = answer
        }
    }
    
    public struct Document: Equatable {
        
        public let title: String
        public let icon: String?
        public let link: String
        
        public init(title: String, icon: String?, link: String) {
            
            self.title = title
            self.icon = icon
            self.link = link
        }
    }
    
    public struct Consent: Equatable {
        
        public let name: String
        public let link: String
        
        public init(name: String, link: String) {
            
            self.name = name
            self.link = link
        }
    }
    
    public struct Icons: Equatable {
        
        public let productName: String
        public let amount: String
        public let term: String
        public let rate: String
        public let city: String
        
        public init(
            productName: String,
            amount: String,
            term: String,
            rate: String,
            city: String
        ) {
            self.productName = productName
            self.amount = amount
            self.term = term
            self.rate = rate
            self.city = city
        }
    }
}

extension GetCollateralLandingProduct.Theme {
    
    public func map() -> CollateralLoanLandingGetCollateralLandingTheme {

        switch self {

        case .white:
            return .white
        case .gray:
            return .gray
        default:
            return .white
        }
    }
}

extension GetCollateralLandingProduct.FrequentlyAskedQuestion: Hashable {}
