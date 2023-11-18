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
    
    @Published private(set) var route: Route?
    
    private let routeSubject = PassthroughSubject<Route?, Never>()
    
    init(
        route: Route? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.route = route
        
        routeSubject
            // .debounce(for: 0.2, scheduler: scheduler)
            .removeDuplicates()
            .receive(on: scheduler)
            .handleEvents(receiveOutput: {
                print($0 as Any)
            })
            .assign(to: &$route)
    }
}

extension RouteModel {
    
    func setRoute(to route: Route?) {
        
        routeSubject.send(route)
    }
    
    func changeRoute(to route: Route) {
        
        resetRoute()
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.2
        ) { [weak self] in
            
            self?.setRoute(to: route)
        }
    }
}
