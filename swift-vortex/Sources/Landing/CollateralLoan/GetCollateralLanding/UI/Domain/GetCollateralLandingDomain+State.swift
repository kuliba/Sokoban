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
        public var result: Result?

        var isLoading = false
        var iHaveSalaryInCompany = false
        var selectedCollateralType: String
        var selectedMonthPeriod: UInt
        var desiredAmount: UInt

        public init(
            landingID: String,
            bottomSheet: BottomSheet? = nil,
            selectedCollateralType: String = "", // Calculator default value
            selectedMonthPeriod: UInt = 12, // Calculator default value
            desiredAmount: UInt = 3_000_000 // Calculator default value
        ) {
            self.landingID = landingID
            self.bottomSheet = bottomSheet
            self.selectedMonthPeriod = selectedMonthPeriod
            self.selectedCollateralType = selectedCollateralType
            self.desiredAmount = desiredAmount
        }
    }
}

extension GetCollateralLandingDomain.State {
    
    var selectedPeriodTitle: String {
        
        product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.termStringValue ?? ""
    }
    
    var selectedCollateralTitle: String {
        
        product?.calc.collaterals.first { $0.type == selectedCollateralType }?.name ?? ""
    }
    
    var selectedPercentDouble: Double {
        
        iHaveSalaryInCompany
            ? product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.ratePayrollClient ?? .zero
            : product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.rateBase ?? .zero
    }
    
    var selectedPercent: String {
        
        String(format: "%.1f", selectedPercentDouble) + "%"
    }
    
    var formattedDesiredAmount: String {
      
        desiredAmount.formattedCurrency()
    }
    
    func annuity(sumCredit: UInt, percent: Double, months: UInt) -> Double {
        
        let percentPerMonth = percent / 100 / 12;
        let denominator = pow(1 + percentPerMonth, Double(months)) - 1
        return Double(sumCredit) * (percentPerMonth + percentPerMonth / denominator)
    }
    
    var formattedAnnuity: String {
        
        let annuity = annuity(
            sumCredit: desiredAmount,
            percent: selectedPercentDouble,
            months: selectedMonthPeriod
        )
        
        return annuity.formatted(.currency(code: "RUB"))
    }
    
    var selectedBottomSheetItem: GetCollateralLandingDomain.State.BottomSheet.Item? {
        
        bottomSheetItems.first { $0.termMonth == selectedMonthPeriod }
    }
}

extension FloatingPoint {

    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
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

extension GetCollateralLandingDomain.State.BottomSheet.Item {
    
    static let preview = Self(
        id: "",
        termMonth: 12,
        icon: "",
        title: "1 год"
    )
}

extension GetCollateralLandingDomain.State {
    
    public var product: Product? {

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
    
    public func payload(_ product: GetCollateralLandingProduct) -> CreateDraftCollateralLoanApplication {
        
        return .init(
            amount: desiredAmount,
            cities: product.cities,
            consents: product.consents.map { .init(name: $0.name, link: $0.link) },
            icons: .init(
                productName: product.icons.productName,
                amount: product.icons.amount,
                term: product.icons.term,
                rate: product.icons.rate,
                city: product.icons.city
            ),
            maxAmount: product.calc.amount.maxIntValue,
            minAmount: product.calc.amount.minIntValue,
            name: product.name,
            percent: selectedPercentDouble,
            periods: product.calc.rates.map { .init(title: $0.termStringValue, months: $0.termMonth) },
            selectedMonths: selectedMonthPeriod
        )
    }
}

public extension GetCollateralLandingDomain.State {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = GetCollateralLandingProduct.Calc.Rate
    typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
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
