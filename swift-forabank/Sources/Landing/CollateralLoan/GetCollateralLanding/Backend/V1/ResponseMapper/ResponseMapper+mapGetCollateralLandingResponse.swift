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
    ) -> MappingResult<GetCollateralLandingResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetCollateralLandingResponse {
        
        guard
            let serial = data.serial,
            let products = data.products
        else {
            throw InvalidResponse()
        }
        
        return .init(list: products.compactMap(\.data), serial: serial)
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data.Product {
    
    var data: ResponseMapper.CollateralLandingProduct? {
        
        guard
            let name,
            let marketing = marketing?.data,
            let conditions,
            let calc = calc?.data,
            let frequentlyAskedQuestions,
            let documents,
            let consents,
            let cities,
            let icons = icons?.data
        else { return nil }
        
        return .init(
            theme: themeMap,
            name: name,
            marketing: marketing,
            conditions: conditions.compactMap(\.data),
            calc: calc,
            frequentlyAskedQuestions: frequentlyAskedQuestions.compactMap(\.data),
            documents: documents.compactMap(\.data),
            consents: consents.compactMap(\.data),
            cities: cities,
            icons: icons
        )
    }
}

private extension ResponseMapper._Data.Product.Calc {
    
    var data: ResponseMapper.CollateralLandingProduct.Calc? {
        
        guard
            let amount = amount?.data,
            let collateral,
            let rates
        else {
            return nil
        }
        
        return .init(
            amount: amount,
            collateral: collateral.compactMap(\.data),
            rates: rates.compactMap(\.data)
        )
    }
}

private extension ResponseMapper._Data.Product.Icons {
    
    var data: ResponseMapper.CollateralLandingProduct.Icons? {
        
        guard
            let productName,
            let amount,
            let term,
            let rate,
            let city
        else {
            return nil
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

private extension ResponseMapper._Data.Product.Consent {
    
    var data: ResponseMapper.CollateralLandingProduct.Consent? {
        
        guard
            let name,
            let link
        else {
            return nil
        }
        
        return .init(
            name: name,
            link: link
        )
    }
}

private extension ResponseMapper._Data.Product.Document {
    
    var data: ResponseMapper.CollateralLandingProduct.Document? {
        
        guard
            let title,
            let link
        else {
            return nil
        }
        
        return .init(
            title: title,
            icon: icon,
            link: link
        )
    }
}

private extension ResponseMapper._Data.Product.FrequentlyAskedQuestion {
    
    var data: ResponseMapper.CollateralLandingProduct.FrequentlyAskedQuestion? {
        
        guard
            let question,
            let answer
        else { return nil }
        
        return .init(
            question: question,
            answer: answer
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Rate {
    
    var data: ResponseMapper.CollateralLandingProduct.Calc.Rate? {
        
        guard
            let rateBase,
            let ratePayrollClient,
            let termMonth,
            let termStringValue
        else { return nil }
        
        return .init(
            rateBase: rateBase,
            ratePayrollClient: ratePayrollClient,
            termMonth: termMonth,
            termStringValue: termStringValue
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Collateral {
    
    var data: ResponseMapper.CollateralLandingProduct.Calc.Collateral? {
        
        guard
            let icon,
            let name,
            let type
        else { return nil }
        
        return .init(
            icon: icon,
            name: name,
            type: type
        )
    }
}

private extension ResponseMapper._Data.Product.Calc.Amount {
    
    var data: ResponseMapper.CollateralLandingProduct.Calc.Amount? {
        
        guard
            let minIntValue,
            let maxIntValue,
            let maxStringValue
        else { return nil }
        
        return .init(
            minIntValue: minIntValue,
            maxIntValue: maxIntValue,
            maxStringValue: maxStringValue
        )
    }
}

private extension ResponseMapper._Data.Product.Condition {
    
    var data: ResponseMapper.CollateralLandingProduct.Condition? {
        
        guard
            let icon,
            let title,
            let subTitle
        else { return nil }
        
        return .init(
            icon: icon,
            title: title,
            subTitle: subTitle
        )
    }
}

private extension ResponseMapper._Data.Product.Marketing {
    
    var data: ResponseMapper.CollateralLandingProduct.Marketing? {
        
        guard
            let labelTag,
            let image,
            let params
        else { return nil }
        
        return .init(
            labelTag: labelTag,
            image: image,
            params: params
        )
    }
}

private extension ResponseMapper._Data.Product {
    
    typealias Theme = ResponseMapper.CollateralLandingProduct.Theme
    
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
        
        let serial: String?
        let products: [Product]?
        
        struct Product: Decodable {
            
            let theme: String?
            let name: String?
            let marketing: Marketing?
            let conditions: [Condition]?
            let calc: Calc?
            let frequentlyAskedQuestions: [FrequentlyAskedQuestion]?
            let documents: [Document]?
            let consents: [Consent]?
            let cities: [String]?
            let icons: Icons?
            
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
