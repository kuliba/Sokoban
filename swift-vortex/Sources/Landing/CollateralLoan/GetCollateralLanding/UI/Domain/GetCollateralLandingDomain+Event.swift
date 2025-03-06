//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent<InformerPayload> {
        
        case domainEvent(Event<InformerPayload>)
        case externalEvent(ExternalEvent<InformerPayload>)
    }

    public enum Event<InformerPayload> {
        
        case changeDesiredAmount(UInt)
        case load(String)
        case loaded(Result<InformerPayload>)
        case selectCaseList(String, String)
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case togglePayrollClient(Bool)
        case dismissFailure
    }
        
    public enum ExternalEvent<InformerPayload>: Equatable {
        
        case createDraftApplication(Product)
        case showCaseList(State<InformerPayload>.BottomSheet.SheetType)
        case openDocument(String)
    }
    
    public typealias Period = Product.Calc.Rate
    public typealias Collateral = Product.Calc.Collateral
    public typealias Product = GetCollateralLandingProduct
}
