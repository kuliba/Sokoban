//
//  CollateralLoanLandingViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 23.12.2024.
//

import CollateralLoanLandingGetShowcaseUI
import RxViewModel

enum CollateralLoanLandingDomain {
    
    typealias ShowCase = CollateralLoanLandingGetShowcaseData
    typealias Result = Swift.Result<ShowCase, LoadResultFailure>
    
    struct State: Equatable {
        
        var isLoading = false
        var result: Result?
        var selected: String?
    }
    
    typealias ViewModel = RxViewModel<State, Event, Effect>
    
    enum Event: Equatable {
        
        case load
        case loaded(Result)
        case productTap(String)
    }
    
    enum Effect: Equatable {
        
        case load
    }
    
    struct LoadResultFailure: Equatable, Error {}
}


extension CollateralLoanLandingDomain {
    
    final class Reducer {
        
        func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case .load:
                guard !state.isLoading else { break }
                        
                state.isLoading = true
                effect = .load
                
            case let .loaded(result):
                state.isLoading = false
                state.result = result
                
            case let .productTap(productType):
                // TODO: Need to realize
                print(productType)
                break
            }
            
            return (state, effect)
        }
    }
}

extension CollateralLoanLandingDomain {
    
    final class EffectHandler {
        
        let load: Load
        
        init(
            load: @escaping Load
        ) {
            self.load = load
        }

        func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
                
            case .load:
                load { dispatch(.loaded($0)) }
            }
        }

        typealias Dispatch = (Event) -> Void
        typealias Load = (@escaping (Result<ShowCase, LoadResultFailure>) -> Void) -> Void
    }
    
}
