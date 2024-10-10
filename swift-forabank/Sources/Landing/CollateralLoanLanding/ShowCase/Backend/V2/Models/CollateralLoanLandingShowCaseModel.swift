//
//  CollateralLoanLandingShowCaseModel.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 07.10.2024.
//

import RemoteServices

extension ResponseMapper {
    public struct CollateralLoanLandingShowCaseModel: Equatable {
        let serial: String
        let products: [Product]
        
        struct Product: Equatable {
            let theme: Theme?
            let name: String?
            let terms: String?
            let landingId: String?
            let image: String?
            let keyMarketingParams: KeyMarketingParams?
            let features: Features?
            
            enum Theme {
                case gray
                case white
                case unknown
            }
            
            struct KeyMarketingParams: Equatable {
                let rate: String?
                let amount: String?
                let term: String?
            }
            
            struct Features: Equatable {
                let header: String?
                let list: [List]?
                
                struct List: Equatable {
                    let bullet: Bool?
                    let text: String?
                }
            }
        }
    }
}
