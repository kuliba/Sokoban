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
    
    let landing: UILanding
    let config: UILanding.Component.Config

    private let destinationSubject = PassthroughSubject<Destination?, Never>()
    
    public init(
        landing: UILanding,
        config: UILanding.Component.Config,
        destination: Destination? = nil,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.landing = landing
        self.config = config
        self.destination = destination
        
        destinationSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$destination)
    }
        
    func setDestination(to destination: Destination?) {
        
        destinationSubject.send(destination)
    }
    
    func selectDetail(_ detail: DetailDestination?) {
        
        if let detail {
            let components = landing.components(
                g: detail.groupID.rawValue,
                v: detail.viewID.rawValue)
            destinationSubject.send(.detail(components))
        } else { destinationSubject.send(nil) } // close bottomsheet
    }
}

// MARK: - Types

extension LandingViewModel {
    
    public enum Destination: Equatable, Identifiable {
        
        case detail([UILanding.Component])
        
        public var id: Case {
            
            switch self {
            case .detail:
                return .detail
            }
        }
        
        public enum Case {
            
            case detail
        }
    }
}
