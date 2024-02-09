//
//  CardGuardianFactory.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import CardGuardianModule

public struct CardGuardianFactory {
    
    public let cardGuardianViewModel: CardGuardianViewModel
    
    public init(cardGuardianViewModel: CardGuardianViewModel) {
        self.cardGuardianViewModel = cardGuardianViewModel
    }
}

public extension CardGuardianFactory {

    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
}
