//
//  RouteModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Combine
import CombineSchedulers
import Foundation

final class RouteModel: ObservableObject {
    
    @Published private(set) var route: Route
    
    private let routeSubject = PassthroughSubject<Route, Never>()
    
    init(
        route: Route = .empty,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.route = route
        
        routeSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$route)
    }
}

extension RouteModel {
    
    func setDestination(to destination: Route.Destination?) {
        
        var route = route
        route.destination = destination
        
        routeSubject.send(route)
    }
    
    func setModal(to modal: Route.Modal?) {
        
        var route = route
        route.modal = modal
        
        routeSubject.send(route)
    }
    
    func resetDestination() {
        
        setDestination(to: nil)
    }
    
    func resetModel() {
        
        setModal(to: nil)
    }
}
