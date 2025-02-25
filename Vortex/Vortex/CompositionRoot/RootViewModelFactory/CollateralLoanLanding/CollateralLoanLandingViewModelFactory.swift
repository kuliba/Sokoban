//
//  CollateralLoanLandingViewModelFactory.swift
//  Vortex
//
//  Created by Valentin Ozerov on 19.02.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import Combine
import SwiftUI
import UIPrimitives

struct CollateralLoanLandingViewModelFactory {
    
    let model: Model
    let makeImageViewWithMD5Hash: (String) -> UIPrimitives.AsyncImage
    
    func makeOperationDetailInfoViewModel(
        payload: CollateralLandingApplicationSaveConsentsResult,
        dismiss: @escaping () -> Void
    ) -> OperationDetailInfoViewModel {
        
        OperationDetailInfoViewModel(
            model: model,
            logo: nil,
            cells: payload.makeCells(
                config: .default,
                makeImageViewWithMD5Hash: makeImageViewWithMD5Hash,
                formatCurrency: { model.amountFormatted(
                    amount: Double($0),
                    currencyCode: "RUB",
                    style: .normal
                )}
            ),
            dismissAction: dismiss
        )
    }
}

extension CollateralLoanLandingViewModelFactory {
    
    static let preview = Self(
        model: .emptyMock,
        makeImageViewWithMD5Hash: { _ in .preview }
    )
}

private extension CollateralLandingApplicationSaveConsentsResult {
    
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
                iconType: config.icons.period,
                title: config.titles.period,
                value: term
            ),
            .init(
                iconType: config.icons.percent,
                title: config.titles.percent,
                value: String(format: "%.1f", interestRate) + "%"
            )
        ]
        
        if let amount = formatCurrency(amount) {
            
            out.append(
                .init(
                    iconType: config.icons.amount,
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
                iconType: config.icons.home,
                title: config.titles.city,
                value: cityName
            )
        )
        
        return out
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Result {
    
    static let `default` = Self(
        titles: .default,
        icons: .default
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Titles {
    
    static let `default` = Self(
        productName: "Наименование кредита",
        period: "Срок кредита",
        percent: "Процентная ставка",
        amount: "Сумма кредита",
        collateralType: "Тип залога",
        city: "Город получения кредита"
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Icons {
    
    static let `default` = Self(
        period: .ic24Calendar,
        percent: .ic24Percent,
        amount: .ic24Coins,
        more: .ic24MoreHorizontal,
        car: .ic24Car,
        home: .ic24Home,
        city: .ic24Egrn
    )
}
