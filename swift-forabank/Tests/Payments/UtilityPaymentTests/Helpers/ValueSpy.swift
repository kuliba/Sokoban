//
//  ValueSpy.swift
//  
//
//  Created by Igor Malyarov on 19.02.2023.
//

import Combine

final class ValueSpy<Value> {
    
    private (set) var events = [Event]()
    private var cancellables: AnyCancellable?
    
    init<P>(_ publisher: P) where P: Publisher, P.Output == Value {
        
        self.cancellables = publisher.sink(
            receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    self?.events.append(.finished)
                    
                case .failure:
                    self?.events.append(.failure)
                }
            },
            receiveValue: { [weak self] value in
                
                self?.events.append(.value(value))
            }
        )
    }
    
    var values: [Value] { events.compactMap(\.value) }
    
    enum Event {
        
        case failure
        case finished
        case value(Value)
        
        var value: Value? {
            
            guard case let .value(value) = self
            else { return nil }
            
            return value
        }
    }
}
