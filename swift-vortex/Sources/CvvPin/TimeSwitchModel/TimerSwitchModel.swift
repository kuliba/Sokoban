//
//  TimerSwitchModel.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import Combine

public final class TimerSwitchModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let subject = PassthroughSubject<DelayedState, Never>()
    
    public init(
        initialState: State = .off,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        
        subject
            .flatMap {
                Just($0.state)
                    .delay(
                        for: .milliseconds($0.delayMS),
                        scheduler: scheduler
                    )
            }
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    public func turnOn(forMS delay: Int) {
        
        subject.send(.init(state: .on, delayMS: 0))
        subject.send(.init(state: .off, delayMS: delay))
    }
    
    public func turnOff() {
        
        subject.send(.init(state: .off, delayMS: 0))
    }
    
    public enum State {
        
        case off, on
    }
    
    private struct DelayedState {
        
        let state: State
        let delayMS: Int
    }
}
