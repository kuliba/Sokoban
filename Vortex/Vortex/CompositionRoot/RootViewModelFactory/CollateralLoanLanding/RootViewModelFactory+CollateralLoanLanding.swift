//
//  RootViewModelFactory+CollateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 26.02.2025.
//

import UIPrimitives

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension CollateralLandingApplicationSaveConsentsResult {
    
    func makeCells(
        config: CreateDraftCollateralLoanApplicationConfig.Result,
        makeImageViewWithMD5Hash: @escaping (String) -> UIPrimitives.AsyncImage,
        formatCurrency: @escaping (UInt) -> String?
    ) -> [OperationDetailInfoViewModel.AsyncPropertyCellViewModel] {
        
        var out: [OperationDetailInfoViewModel.AsyncPropertyCellViewModel] =
        [
            .init(
                asyncImage: makeImageViewWithMD5Hash(icons.productName),
                title: config.titles.productName,
                value: name
            ),
            .init(
                asyncImage: makeImageViewWithMD5Hash(icons.term),
                title: config.titles.period,
                value: term
            ),
            .init(
                asyncImage: makeImageViewWithMD5Hash(icons.rate),
                title: config.titles.percent,
                value: String(format: "%.1f", interestRate) + "%"
            )
        ]
        
        if let amount = formatCurrency(amount) {
            
            out.append(
                .init(
                    asyncImage: makeImageViewWithMD5Hash(icons.amount),
                    title: config.titles.amount,
                    value: amount
                )
            )
        }
        
        if let description {
            
            var iconType = config.icons.more
            
            if ["CAR", "OTHER_MOVABLE_PROPERTY"].contains(collateralType) {
                
                iconType = config.icons.car
            } else if ["APARTMENT", "HOUSE", "LAND_PLOT", "COMMERCIAL_PROPERTY"].contains(collateralType) {
                
                iconType = config.icons.home
            }
            
            out.append(
                .init(
                    iconType: iconType,
                    title: config.titles.collateralType,
                    value: description
                )
            )
        }
        
        out.append(
            .init(
                asyncImage: makeImageViewWithMD5Hash(icons.city),
                title: config.titles.city,
                value: cityName
            )
        )
        
        return out
    }
}
