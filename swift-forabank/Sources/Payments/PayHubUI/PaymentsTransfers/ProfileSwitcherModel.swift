//
//  ProfileSwitcherModel.swift
//  
//
//  Created by Igor Malyarov on 29.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

public final class ProfileSwitcherModel<Corporate, Personal>: ObservableObject {
    
    @Published public private(set) var state: State
    
    public init(
        isCorporateOnly: AnyPublisher<Bool, Never>,
        corporate: Corporate,
        personal: Personal,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = .personal(personal)
        
        isCorporateOnly
            .removeDuplicates()
            .map { $0 ? .corporate(corporate) : .personal(personal) }
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension ProfileSwitcherModel {

    typealias State = ProfileState<Corporate, Personal>
}
