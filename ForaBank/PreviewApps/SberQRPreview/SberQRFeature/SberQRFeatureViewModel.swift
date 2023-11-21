//
//  SberQRFeatureViewModel.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 20.11.2023.
//

import Combine
import Foundation

#warning("has the same shape as RouteModel - make RouteModel generic")
final class SberQRFeatureViewModel: ObservableObject {
    
    @Published private(set) var route: SberQRFeatureRoute?
    
    private let routeSubject = PassthroughSubject<SberQRFeatureRoute?, Never>()
    
    init(
        route: SberQRFeatureRoute? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.route = route
        
        routeSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .handleEvents(receiveOutput: { print($0 as Any) })
            .assign(to: &$route)
    }
}

extension SberQRFeatureViewModel {
    
    func resetRoute() {
        
        routeSubject.send(nil)
    }
    
    func setRoute(
        url: URL,
        completion: @escaping SberQRFeatureRoute.Completion
    ) {
        routeSubject.send(.init(url: url, completion: completion))
    }
    
    func consumeRoute(text: String) {
        
        self.route?.completion(text)
        resetRoute()
    }
}
