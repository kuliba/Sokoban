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
        case showCaseList(CaseType)
        case openDocument(String)

        public enum CaseType: Equatable {
            
            case periods([Period])
            case collaterals([Collateral])
        }
    }
    
    public typealias Period = GetCollateralLandingProduct.Calc.Rate
    public typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
    public typealias Product = GetCollateralLandingProduct
}
