//
//  GetCollateralLandingDomain+State.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Foundation

extension GetCollateralLandingDomain {
    
    public struct State<InformerPayload> {
        
        public let landingID: String
        public var bottomSheet: BottomSheet?
        public var result: Result<InformerPayload>?
        public var desiredAmount: UInt
        public var selectedMonthPeriod: UInt
        public var payrollClient = false
        public var selectedCollateralType: String

        var isLoading = false

        let formatCurrency: FormatCurrency
        
        public init(
            landingID: String,
            bottomSheet: BottomSheet? = nil,
            result: Result<InformerPayload>? = nil,
            selectedCollateralType: String = "", // Calculator default value
            selectedMonthPeriod: UInt = 12, // Calculator default value
            desiredAmount: UInt = 3_000_000, // Calculator default value
            formatCurrency: @escaping FormatCurrency
        ) {
            self.landingID = landingID
            self.bottomSheet = bottomSheet
            self.result = result
            self.selectedMonthPeriod = selectedMonthPeriod
            self.selectedCollateralType = selectedCollateralType
            self.desiredAmount = desiredAmount
            self.formatCurrency = formatCurrency
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
    
    public var selectedPercentDouble: Double {
        
        payrollClient
            ? product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.ratePayrollClient ?? .zero
            : product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.rateBase ?? .zero
    }
    
    var selectedPercent: String {
        
        String(format: "%.1f", selectedPercentDouble) + "%"
    }
    
    var formattedDesiredAmount: String? {
      
        formatCurrency(desiredAmount)
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
    
    var selectedBottomSheetItem: GetCollateralLandingDomain.State<InformerPayload>.BottomSheet.Item? {
        
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
            
            case periods([Period])
            case collaterals([Collateral])
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
    
    static var preview: Self { Self(
        id: "",
        termMonth: 12,
        icon: "",
        title: "1 год"
    )}
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
            return product.calc.rates.map { .init(rate: $0) }

        case .collaterals:
            return product.calc.collaterals.map { .init(collateral: $0) }
        }
    }
}

public extension GetCollateralLandingDomain.State {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = GetCollateralLandingProduct.Calc.Rate
    typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
    typealias FormatCurrency = (UInt) -> String?
}
