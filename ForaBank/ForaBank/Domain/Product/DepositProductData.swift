//
//  DepositProductData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.03.2022.
//

import Foundation

struct DepositProductData: Codable, Equatable, Cachable {
    
    let depositProductID: Int
    let detailedСonditions: [DetailedСondition]
    let documentsList: [DocumentsData]
    let generalСondition: GeneralConditionData
    let name: String
    let termRateList: [TermCurrencyRate]
    let termRateCapList: [TermCurrencyRate]?
    let txtСondition: [String]
}

extension DepositProductData {
    
    struct TermCurrencyRate: Codable, Equatable {
        
        let termRateSum: [TermRateSum]
        let сurrencyCode: String
        let сurrencyCodeTxt: String
        
        struct TermRateSum: Codable, Equatable {
            
            let sum: Double
            let termRateList: [TermRate]
            
            struct TermRate: Codable, Equatable {
                
                let rate: Double
                let term: Int
                let termName: String
                //TODO: decoder for termABS to termAbs
                let termABS: Int?
                let termKind: Int?
                let termType: Int?
            }
        }
    }
    
    struct DetailedСondition: Codable, Equatable {
        
        let desc: String
        let enable: Bool
    }
    
    struct DocumentsData: Codable, Equatable {
        
        let name: String
        let url: URL
    }
    
    struct GeneralConditionData: Codable, Equatable {
        
        let design: DesignData
        let formula: String
        let generalTxtСondition: [String]
        let imageLink: String
        let maxRate: Double
        let maxSum: Double
        let maxTerm: Int
        let maxTermTxt: String
        let minSum: Double
        let minSumCur: String
        let minTerm: Int
        
        struct DesignData: Codable, Equatable {
            
            let background: [ColorData]
            let textColor: [ColorData]
        }
    }
}
