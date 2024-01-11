//
//  ViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

final class ViewModel: ObservableObject {
    
    @Published private(set) var route: Route
    
    init(route: Route = .init()) {
        
        self.route = route
    }
}

extension ViewModel {
    
    func openFastPaymentsSettings() {
        
        route.destination = .fastPaymentsSettings
    }
}

extension ViewModel {
    
    func resetDestination() {
        
        route.destination = nil
    }
}

extension ViewModel {
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
        
        init(
            destination: Destination? = nil,
            modal: Modal? = nil
        ) {
            self.destination = destination
            self.modal = modal
        }
        
        enum Destination {
            
            case fastPaymentsSettings
        }
        
        enum Modal {
            
            case alert
        }
    }
}
