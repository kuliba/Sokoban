//
//  NavigationModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Combine
import CombineSchedulers
import Foundation

final class NavigationModel: ObservableObject {
    
    @Published private(set) var navigation: Navigation?
    
    private let navigationSubject = PassthroughSubject<Navigation?, Never>()
    
    init(
        navigation: Navigation? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.navigation = navigation
        
        navigationSubject
            // .debounce(for: 0.2, scheduler: scheduler)
            .removeDuplicates()
            .receive(on: scheduler)
            .handleEvents(receiveOutput: {
                print($0 as Any)
            })
            .assign(to: &$navigation)
    }
}

extension NavigationModel {
    
    func setNavigation(to navigation: Navigation?) {
        
        navigationSubject.send(navigation)
    }
    
    func changeNavigation(to navigation: Navigation) {
        
        resetNavigation()
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.2
        ) { [weak self] in
            
            self?.setNavigation(to: navigation)
        }
    }
}
