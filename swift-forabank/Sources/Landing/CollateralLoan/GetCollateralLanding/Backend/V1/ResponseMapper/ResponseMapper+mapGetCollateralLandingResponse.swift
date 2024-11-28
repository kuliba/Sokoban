//
//  ResponseMapper+mapGetCollateralLandingResponse.swift
//  
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateGetCollateralLandingResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetCollateralLandingData> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetCollateralLandingData {

        try data.getGetCollateralLandingData()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getGetCollateralLandingData() throws -> ResponseMapper.GetCollateralLandingData {
        
        guard
            let product
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            product: try product.map()
        )
    }
}

private extension ResponseMapper._Data.Product {

    func map() throws -> ResponseMapper.GetCollateralLandingData.Product {
        
        guard
            let theme,
            let name,
            let marketing,
            let conditions,
            let calc
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            theme: themeMap,
            name: name,
            marketing: try marketing.map(),
            conditions: try conditions.map { try $0.map() },
            calc: try calc.map()
        )
    }
}

private extension ResponseMapper._Data.Product.Calc {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc {
        
        guard
            let amount,
            let collateral,
            let rates,
            let frequentlyAskedQuestions,
            let documents,
            let consents,
            let cities,
            let icons
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            amount: try amount.map(),
            collateral: try collateral.map { try $0.map() },
            rates: try rates.map { try $0.map() },
            frequentlyAskedQuestions: try frequentlyAskedQuestions.map { try $0.map() },
            documents: try documents.map { try $0.map() },
            consents: try consents.map { try $0.map() },
            cities: cities,
            icons: try icons.map()
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Icons {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Icons {
        
        guard
            let productName,
            let amount,
            let term,
            let rate,
            let city
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            productName: productName,
            amount: amount,
            term: term,
            rate: rate,
            city: city
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Consent {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Consent {
        
        guard
            let name,
            let link
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            name: name,
            link: link
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Document {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Document {
        
        guard
            let title,
            let link
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            title: title,
            icon: icon,
            link: link
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.FrequentlyAskedQuestion {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.FrequentlyAskedQuestion {
        
        guard
            let question,
            let answer
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            question: question,
            answer: answer
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Rate {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Rate {
        
        guard
            let rateBase,
            let ratePayrollClient,
            let termMonth,
            let termStringValue
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            rateBase: rateBase,
            ratePayrollClient: ratePayrollClient,
            termMonth: termMonth,
            termStringValue: termStringValue
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Collateral {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Collateral {
        
        guard
            let icon,
            let name,
            let type
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            icon: icon,
            name: name,
            type: type
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Amount {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Calc.Amount {
        
        guard
            let minIntValue,
            let maxIntValue,
            let maxStringValue
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            minIntValue: minIntValue,
            maxIntValue: maxIntValue,
            maxStringValue: maxStringValue
        )
    }
}

private extension ResponseMapper._Data.Product.Condition {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Condition {
        
        guard
            let icon,
            let title,
            let subTitle
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            icon: icon,
            title: title,
            subTitle: subTitle
        )
    }
}

private extension ResponseMapper._Data.Product.Marketing {
    
    func map() throws -> ResponseMapper.GetCollateralLandingData.Product.Marketing {
        
        guard
            let labelTag,
            let image,
            let params
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            labelTag: labelTag,
            image: image,
            params: params
        )
    }
}

private extension ResponseMapper._Data.Product {

    typealias Theme = ResponseMapper.GetCollateralLandingData.Product.Theme
    
    var themeMap: Theme {
        
        var theme = Theme.unknown
        
        if let themeFromData = self.theme,
           let themeMap = Theme(rawValue: themeFromData.lowercased()) {
            theme = themeMap
        }

        return theme
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let product: Product?
        
        struct Product: Decodable {

            let theme: String?
            let name: String?
            let marketing: Marketing?
            let conditions: [Condition]?
            let calc: Calc?

            struct Marketing: Decodable {
                
                let labelTag: String?
                let image: String?
                let params: [String]?
            }
            
            struct Condition: Decodable {
                
                let icon: String?
                let title: String?
                let subTitle: String?
            }
            
            struct Calc: Decodable {
                
                let amount: Amount?
                let collateral: [Collateral]?
                let rates: [Rate]?
                let frequentlyAskedQuestions: [FrequentlyAskedQuestion]?
                let documents: [Document]?
                let consents: [Consent]?
                let cities: [String]?
                let icons: Icons?
                
                struct Amount: Decodable {
                    
                    let minIntValue: UInt?
                    let maxIntValue: UInt?
                    let maxStringValue: String?
                }
                
                struct Collateral: Decodable {
                    
                    let icon: String?
                    let name: String?
                    let type: String?
                }
                
                struct Rate: Decodable {
                    
                    let rateBase: Double?
                    let ratePayrollClient: Double?
                    let termMonth: UInt?
                    let termStringValue: String?
                }
                
                struct FrequentlyAskedQuestion: Decodable {
                    
                    let question: String?
                    let answer: String?
                }
                
                struct Document: Decodable {
                    
                    let title: String?
                    let icon: String?
                    let link: String?
                }
                
                struct Consent: Decodable {
                    
                    let name: String?
                    let link: String?
                }
                
                struct Icons: Decodable {
                    
                    let productName: String?
                    let amount: String?
                    let term: String?
                    let rate: String?
                    let city: String?
                }
            }
        }
    }
}
