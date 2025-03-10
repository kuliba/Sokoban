//
//  GetCollateralLandingDomain+State.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Foundation
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension GetCollateralLandingDomain {
    
    public struct State<InformerPayload> {
        
        public var status: Status<InformerPayload>
        public let landingID: String
        public var bottomSheet: BottomSheet?
        
        var backendFailure: BackendFailure<InformerPayload>?
        var payrollClient = false
        var selectedCollateralType: String
        var selectedMonthPeriod: UInt
        var desiredAmount: UInt

        let formatCurrency: FormatCurrency
        
        public init(
            status: Status<InformerPayload> = .initiate,
            landingID: String,
            bottomSheet: BottomSheet? = nil,
            backendFailure: BackendFailure<InformerPayload>? = nil,
            selectedCollateralType: String = "", // Calculator default value
            selectedMonthPeriod: UInt = 12, // Calculator default value
            desiredAmount: UInt = 3_000_000, // Calculator default value
            formatCurrency: @escaping FormatCurrency
        ) {
            self.status = status
            self.landingID = landingID
            self.bottomSheet = bottomSheet
            self.backendFailure = backendFailure
            self.selectedMonthPeriod = selectedMonthPeriod
            self.selectedCollateralType = selectedCollateralType
            self.desiredAmount = desiredAmount
            self.formatCurrency = formatCurrency
        }
    }
    
    public enum Status<InformerPayload> {
        
        case initiate
        case inflight(Product?)
        case loaded(Product)
        case failure(Failure, Product?)
        
        var isLoading: Bool {
            
            switch self {
            case .inflight:
                return true
            case .initiate, .failure, .loaded:
                return false
            }
        }
        
        var oldProduct: Product? {
            
            switch self {
            case let .loaded(product):
                return product
                
            case let .failure(_, product):
                return product
                
            case let .inflight(product):
                return product

            case .initiate:
                return nil
            }
        }

        public enum Failure {
            
            case alert(String)
            case informer(InformerPayload)
        }
    }
}

extension GetCollateralLandingDomain.State {
    
    var product: Product? {
        
        if case .loaded(let product) = status { return product } else { return nil }
    }
    
    var isButtonDisabled: Bool {
        
        if let product,
        desiredAmount >= product.calc.amount.minIntValue && desiredAmount <= product.calc.amount.maxIntValue {
        
            return false
        } else { return true }
    }
    
    var selectedPeriodTitle: String {
        
        product?.calc.rates.first { $0.termMonth == selectedMonthPeriod }?.termStringValue ?? ""
    }
    
    var selectedCollateralTitle: String {
        
        product?.calc.collaterals.first { $0.type == selectedCollateralType }?.name ?? ""
    }
    
    var selectedPercentDouble: Double {
        
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

extension GetCollateralLandingDomain.State {
    
    public var failure: GetCollateralLandingDomain.Status<InformerPayload>.Failure? {
        
        if case let .failure(failure, _) = status {
     
                return failure
        }
        
        return nil
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
            selectedMonths: selectedMonthPeriod,
            payrollClient: payrollClient,
            collateralType: selectedCollateralType
        )
    }
}

public extension GetCollateralLandingDomain.State {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = Product.Calc.Rate
    typealias Collateral = Product.Calc.Collateral
    typealias FormatCurrency = (UInt) -> String?
}
