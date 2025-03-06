//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent<InformerPayload> {
        
        case domainEvent(Event<InformerPayload>)
        case externalEvent(ExternalEvent)
    }

    public enum Event<InformerPayload> {
        
        case changeDesiredAmount(UInt)
        case enterDesiredAmount(String)
        case load(String)
        case loaded(Result<InformerPayload>)
        case selectCaseList(String, String)
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case togglePayrollClient(Bool)
        case dismissFailure
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
