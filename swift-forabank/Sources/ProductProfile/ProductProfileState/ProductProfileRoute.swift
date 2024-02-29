//
//  ProductProfileRoute.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianUI
import UIPrimitives
import Foundation

public extension ProductProfileNavigation.State {
    
    typealias ProductProfileRoute = GenericRoute<CardGuardianViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>
}
