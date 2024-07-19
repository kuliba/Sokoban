//
//  ListHorizontalRectangleLimitsReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives
import SwiftUI
import Combine

public final class ListHorizontalRectangleLimitsReducer {
    
    public init() {}
}

public extension ListHorizontalRectangleLimitsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        case let .updateLimits(result):
            switch result {
            case .failure:
                state.limitsLoadingStatus = .failure
            case let .success(limits):
                state.limitsLoadingStatus = .limits(limits)
            }
            
        case let .buttonTapped(info):
            switch info.action {
            case "changeLimit":
                state.limitsLoadingStatus = .inflight(.loadingSettingsLimits)
                
                let landing: UILanding = .init(
                    header: [.pageTitle(.defaultValue1)],
                    main: [
                        .blockHorizontalRectangular(.defaultValue)
                    ],
                    footer: [],
                    details: [])
                
                state.destination = .settingsView(
                    .init(initialState: .success(landing),
                          imagePublisher: { Just(["1": Image.bolt])
                              .eraseToAnyPublisher() }(),
                          imageLoader: { _ in },
                          makeIconView: { _ in .init(
                              image: .flag,
                              publisher: Just(.percent).eraseToAnyPublisher()
                          )},
                          limitsViewModel: nil,
                          config: .defaultValue,
                          landingActions: {_ in }))

            default:
                break
            }
         
        case let .loadedLimits(landing):
            state.destination = .settingsView(
                .init(initialState: .success(landing),
                      imagePublisher: { Just(["1": Image.bolt])
                          .eraseToAnyPublisher() }(),
                      imageLoader: { _ in },
                      makeIconView: { _ in .init(
                          image: .flag,
                          publisher: Just(.percent).eraseToAnyPublisher()
                      )},
                      limitsViewModel: nil,
                      config: .defaultValue,
                      landingActions: {_ in }))
        case .dismissDestination:
            state.destination = nil
        }
        
        return (state, effect)
    }
}

public extension ListHorizontalRectangleLimitsReducer {
    
    typealias State = ListHorizontalRectangleLimitsState
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Effect = ListHorizontalRectangleLimitsEffect
}
