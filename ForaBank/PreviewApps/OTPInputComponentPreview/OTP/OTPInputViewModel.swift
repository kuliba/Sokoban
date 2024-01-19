//
//  OTPInputViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import RxViewModel

typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

extension OTPInputViewModel {
    
    func edit(_ text: String) {
        
        self.event(.edit(text))
    }
}

extension OTPInputViewModel {
    
    static func `default`(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let reducer = OTPInputReducer()
        let effectHandler = OTPInputEffectHandler()
        
        return .init(
            initialState: .init(text: ""),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

struct OTPInputState: Equatable {
    
    var text: String
}

enum OTPInputEvent: Equatable {
    
    case edit(String)
}

enum OTPInputEffect: Equatable {}

final class OTPInputReducer {
 
    let length = 6
}

extension OTPInputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .edit(text):
            print(text, "from `edit`")
            let text = text.filter(\.isNumber).prefix(length)
            print(text, "filtered")
            state.text = .init(text)
            print(state.text, "in state")
        }
        
        return (state, effect)
    }
}

extension OTPInputReducer {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

final class OTPInputEffectHandler {
    
}

extension OTPInputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension OTPInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

extension OTPInputState {
    
    var digitModels: [DigitModel] {
        
        #warning("move maxLength to init")
        let length = 6
        return text
            .filter(\.isNumber)
            .padding(toLength: length, withPad: " ", startingAt: 0)
            .map { String($0) }
            .enumerated()
            .map {

                DigitModel(id: $0.offset, value: $0.element)
            }
    }
    
    struct DigitModel: Identifiable {
        
        let id: Int
        let value: String
    }
}
