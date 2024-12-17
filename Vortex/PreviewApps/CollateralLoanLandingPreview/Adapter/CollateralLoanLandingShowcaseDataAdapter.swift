//
//  CollateralLoanLandingShowcaseDataAdapter.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 07.11.2024.
//

import RemoteServices
import CollateralLoanLandingGetShowcaseBackend
import CollateralLoanLandingGetShowcaseUI

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel {
    
    func map() -> CollateralLoanLandingShowCaseData {
        
        .init(products: products.map { $0.map() })
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel.Product {
    
    func map() -> CollateralLoanLandingShowCaseData.Product {
        
        .init(
            theme: theme.map(),
            name: name,
            terms: terms,
            landingId: landingId,
            image: image,
            keyMarketingParams: keyMarketingParams.map(),
            features: features.map()
        )
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Theme {
    
    func map() -> CollateralLoanLandingShowCaseData.Product.Theme {
        
        switch self {
        case .white:
            return .white
        case .gray:
            return .gray
        case .unknown:
            return .unknown
        }
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel.Product.KeyMarketingParams {
    
    func map() -> CollateralLoanLandingShowCaseData.Product.KeyMarketingParams {
        
        .init(
            rate: rate,
            amount: amount,
            term: term
        )
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features {
    
    func map() -> CollateralLoanLandingShowCaseData.Product.Features {
        
        .init(
            header: header,
            list: list.map { $0.map() }
        )
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features.List {
    
    func map() -> CollateralLoanLandingShowCaseData.Product.Features.List {
        
        .init(
            bullet: bullet,
            text: text
        )
    }
}
