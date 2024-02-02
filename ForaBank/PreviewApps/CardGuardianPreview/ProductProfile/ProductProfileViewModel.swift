//
//  ProductProfileViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import Foundation
import Combine
import CombineSchedulers
import UIPrimitives
import CardGuardianModule

final class ProductProfileViewModel: ObservableObject {
    
    @Published private(set) var state: ProductProfileViewModel.State
    
    private let navigationStateManager: ProductProfileNavigationStateManager
    
    private let stateSubject = PassthroughSubject<ProductProfileViewModel.State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        initialState: ProductProfileViewModel.State = .initinal,
        navigationStateManager: ProductProfileNavigationStateManager,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.navigationStateManager = navigationStateManager
        self.scheduler = scheduler
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension ProductProfileViewModel {
    
    enum State: Equatable {
        
        case initinal
        case openPanel
        case toggleLock
        case changePin
        case showOnMain
    }
}

struct ProductProfileNavigationStateManager {
    
    let makeCardGuardianViewModel: MakeCardGuardianViewModel
    
    init(
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel
    ) {
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
    }
}

// MARK: - CardGuardian

extension ProductProfileViewModel {
    
    func openCardGuardian() -> CardGuardianViewModel {
        
        // TODO: add cancellable, event
        return navigationStateManager.makeCardGuardianViewModel(scheduler)
    }
}

// MARK: - Types

extension ProductProfileNavigationStateManager {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
}
