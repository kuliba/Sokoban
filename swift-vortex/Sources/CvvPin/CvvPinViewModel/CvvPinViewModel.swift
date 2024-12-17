//
//  CvvPinViewModel.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import Combine
import Foundation

public final class CvvPinViewModel: ObservableObject {
    
    @Published public private(set) var state: State = .hidden
    
    private let pinLoader: PinLoader
    private let timerSwitchModel: TimerSwitchModel
    private let subject = PassthroughSubject<State, Never>()
    
    public init(
        pinLoader: PinLoader,
        timerSwitchModel: TimerSwitchModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.pinLoader = pinLoader
        self.timerSwitchModel = timerSwitchModel
        
        let hide = timerSwitchModel.$state
            .dropFirst()
            .filter { $0 == .off }
            .map { _ in State.hidden }
        
        subject
            .merge(with: hide)
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    public func showPin() {
        
        pinLoader.getPin { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                subject.send(.error)
                
            case let .success(pin):
                subject.send(.visible(.init(value: pin)))
                timerSwitchModel.turnOn(forMS: 30 * 1_000)
            }
        }
    }
    
    public func hidePin() {
        
        subject.send(.hidden)
    }
    
    public enum State: Equatable {
        
        case error
        case hidden
        case visible(PinCode)
        
        public struct PinCode: Equatable {
            
            let value: String
            
            public init(value: String) {
                
                self.value = value
            }
        }
    }
}
