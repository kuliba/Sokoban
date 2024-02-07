//
//  CGViewModel.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Combine
import Foundation
import RxViewModel
import CardGuardianModule

public final class CGViewModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let viewModel: CardGuardianViewModel
    private var cancellable: AnyCancellable?
    
    public init(
        viewModel: CardGuardianViewModel,
        cancellable: AnyCancellable?,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        self.state = viewModel.state
        self.cancellable = cancellable
        self.viewModel = viewModel
    }
}

public extension CGViewModel {
    
    typealias State = CardGuardianState
    typealias Event = CardGuardianEvent
}

public extension CGViewModel {
    
    func event(_ event: Event) {
        
        viewModel.event(event)
    }
}
