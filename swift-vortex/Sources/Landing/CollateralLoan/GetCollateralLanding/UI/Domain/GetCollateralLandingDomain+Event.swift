//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent<InformerPayload> where InformerPayload: Equatable {
        
        case domainEvent(Event<InformerPayload>)
        case externalEvent(ExternalEvent<InformerPayload>)
    }

    public enum Event<InformerPayload> where InformerPayload: Equatable {
        
        case load(String)
        case loaded(Product)
        case failure(Failure)
        case dismissFailure

        case changeDesiredAmount(UInt)
        case enterDesiredAmount(String)
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case togglePayrollClient(Bool)

        public enum Failure: Equatable {
            
            case alert(String)
            case informer(InformerPayload)
        }
    }
        
    public enum ExternalEvent<InformerPayload>: Equatable where InformerPayload: Equatable {
        
        case createDraftApplication(Product)
        case showCaseList(State<InformerPayload>.BottomSheet.SheetType)
        case openDocument(String)
    }
    
    public typealias Period = Product.Calc.Rate
    public typealias Collateral = Product.Calc.Collateral
    public typealias Product = GetCollateralLandingProduct
}
