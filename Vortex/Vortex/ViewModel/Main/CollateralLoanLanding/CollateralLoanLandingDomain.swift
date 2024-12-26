//
//  CollateralLoanLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 24.12.2024.
//

import CollateralLoanLandingGetShowcaseUI
import RxViewModel

extension CollateralLoanLandingDomain.State {
    
    var showcase: CollateralLoanLandingDomain.ShowCase? {
        
        guard case let .success(showcase) = result
        else { return nil }
        
        return showcase
    }
}

enum CollateralLoanLandingDomain {
    
    struct State: Equatable {
        
        var isLoading = false
        var result: Result?
        var selected: String?
    }
    
    enum Event: Equatable {
        
        case load
        case loaded(Result)
        case productTap(String)
    }
    
    enum Effect: Equatable {
        
        case load
    }
    
    struct LoadResultFailure: Equatable, Error {}
    
    typealias ShowCase = CollateralLoanLandingGetShowcaseData
    typealias Result = Swift.Result<ShowCase, LoadResultFailure>
    typealias ViewModel = RxViewModel<State, Event, Effect>
}
