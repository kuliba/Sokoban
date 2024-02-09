//
//  ProductProfileRoute.swift
//  
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianModule
import UIPrimitives
import Foundation

public extension ProductProfileNavigation.State {
        
    typealias ProductProfileRoute = GenericRoute<CardGuardianViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>
    
    private typealias _ProductProfileRoute = _Destination<CardGuardianState, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>
}

private struct _Destination<State, Destination, Modal, Alert> {
    
    public let state: State
    public var destination: Destination?
    public var modal: Modal?
    public var alert: Alert?
    
    public init(
        state: State,
        destination: Destination? = nil,
        modal: Modal? = nil,
        alert: Alert? = nil
    ) {
        self.state = state
        self.destination = destination
        self.modal = modal
        self.alert = alert
    }
}
