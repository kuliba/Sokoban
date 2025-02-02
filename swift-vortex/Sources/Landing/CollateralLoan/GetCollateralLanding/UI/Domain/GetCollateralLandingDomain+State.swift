//
//  GetCollateralLandingDomain+State.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Foundation
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension GetCollateralLandingDomain {
    
    public struct State: Equatable {
        
        public let landingID: String
        public var bottomSheet: BottomSheet?

        var isLoading = false
        var result: Result?
        var iHaveSalaryInCompany = false
        var selectedCollateral: String?
        var selectedMonthPeriod: UInt?

        public init(
            landingID: String,
            bottomSheet: BottomSheet? = nil
        ) {
            self.landingID = landingID
            self.bottomSheet = bottomSheet
        }
    }
}

extension GetCollateralLandingDomain.State {

    public struct BottomSheet: Equatable, Identifiable {
        
        public let id = UUID()
        public let sheetType: SheetType
        
        public init(sheetType: SheetType) {
            self.sheetType = sheetType
        }
        
        public enum SheetType: Equatable {
            
            case periods
            case collaterals
        }
        
        public struct Item: Equatable, Identifiable {
            
            public let id: String
            
            let termMonth: UInt?
            let icon: String?
            let title: String
        }
    }
}

extension GetCollateralLandingDomain.State {
    
    var product: Product? {

        try? result?.get()
    }
    
    var bottomSheetItems: [BottomSheet.Item] {
        
        guard
            let product,
            let bottomSheet
        else { return [] }
        
        switch bottomSheet.sheetType {
        case .periods:
            return product.calc.rates.map(\.bottomSheetItem)

        case .collaterals:
            return product.calc.collaterals.map(\.bottomSheetItem)
        }
    }
}

extension GetCollateralLandingDomain.State {
    
    public func payload(_ product: GetCollateralLandingProduct) -> CreateDraftCollateralLoanApplicationUIData {
        
        // TODO: Need to get from calculate summ from calculator
        return .init(
            name: product.name,
            amount: 1_234_567,
            minAmount: product.calc.amount.minIntValue,
            maxAmount: product.calc.amount.maxIntValue,
            periods: product.calc.rates.map { .init(title: $0.termStringValue, months: $0.termMonth) },
            selectedMonths: 24,
            percent: 18.54221,
            cities: product.cities,
            selectedCity: "Балабаново",
            icons: .init(
                productName: product.icons.productName,
                amount: product.icons.amount,
                term: product.icons.term,
                rate: product.icons.rate,
                city: product.icons.city
            )
        )
    }
}

public extension GetCollateralLandingDomain.State {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = GetCollateralLandingProduct.Calc.Rate
    typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
}
