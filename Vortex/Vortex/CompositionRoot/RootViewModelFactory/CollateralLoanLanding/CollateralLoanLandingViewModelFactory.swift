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
            cells: payload.makeCells(makeImageViewWithMD5Hash),
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

extension CollateralLandingApplicationSaveConsentsResult {
    
    func makeCells(
        _ makeImageViewWithMD5Hash: @escaping (String) -> UIPrimitives.AsyncImage
    ) -> [OperationDetailInfoViewModel.AsyncPropertyCellViewModel] {

        var out: [OperationDetailInfoViewModel.AsyncPropertyCellViewModel] =
        [
            .init(
                asyncImage: makeImageViewWithMD5Hash(icons.productName),
                title: "Наименование кредита",
                value: name
            ),
            .init(
                iconType: .ic24Calendar,
                title: "Срок кредита",
                value: term
            ),
            .init(
                iconType: .ic24Percent,
                title: "Процентная ставка",
                value: String(format: "%.1f", interestRate) + "%"
            ),
            .init(
                iconType: .ic24Coins,
                title: "Сумма кредита",
                value: amount.formattedCurrency()
            ),
        ]
        
        if let description {
            
            var iconType = Image.ic24MoreHorizontal
            
            if ["CAR", "OTHER_MOVABLE_PROPERTY"].contains(collateralType) {
                
                iconType = .ic24Car
            } else if ["APARTMENT", "HOUSE", "LAND_PLOT", "COMMERCIAL_PROPERTY"].contains(collateralType) {
                
                iconType = .ic24Home
            }
            
            out.append(
                .init(
                    iconType: iconType,
                    title: "Тип залога",
                    value: description
                )
            )
        }
        
        out.append(
            .init(
                iconType: .ic24Egrn,
                title: "Город получения кредита",
                value: cityName
            )
        )
        
        return out
    }
}

extension UInt {
    
    func formattedCurrency(_ currencySymbol: String = "₽") -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = currencySymbol
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.maximumFractionDigits = 0

        if let value = currencyFormatter.string(from: NSNumber(value: self)) {
            return value
        }
        
        return String(self)
    }
}
