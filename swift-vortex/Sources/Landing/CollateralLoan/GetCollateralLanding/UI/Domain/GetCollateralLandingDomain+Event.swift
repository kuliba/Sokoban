//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent: Equatable {
        
        case domainEvent(Event)
        case externalEvent(ExternalEvent)
    }

    public enum Event: Equatable {
        
        case changeDesiredAmount(UInt)
        case load(String)
        case loaded(Result)
        case selectCaseList(String, String)
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case togglePayrollClient(Bool)
    }
        
    public enum ExternalEvent: Equatable {
        
        case createDraftApplication(Product)
        case showCaseList(State.BottomSheet.SheetType)
        case openDocument(String)
    }
    
    public typealias Period = Product.Calc.Rate
    public typealias Collateral = Product.Calc.Collateral
    public typealias Product = GetCollateralLandingProduct
}
