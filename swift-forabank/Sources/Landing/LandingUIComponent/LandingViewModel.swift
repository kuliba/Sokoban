//
//  LandingViewModel.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

import Combine
import CombineSchedulers
import Foundation
import Tagged

public final class LandingViewModel: ObservableObject {
    
    @Published private(set) var destination: Destination?
    
    private let destinationSubject = PassthroughSubject<Destination?, Never>()
    
    public init(
        initialValue: Destination? = nil,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        destination = initialValue
        
        destinationSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$destination)
    }
    
    func setDestination(to destination: Destination?) {
        
        destinationSubject.send(destination)
    }
    
    func selectDetail(_ detail: Detail) {
        
        destinationSubject.send(.detail(detail))
    }
}

// MARK: - Types

extension LandingViewModel {
    
    public enum Destination: Equatable {
        
        case detail(Detail)
    }
}
