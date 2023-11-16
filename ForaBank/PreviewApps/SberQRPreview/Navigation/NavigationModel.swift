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
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$navigation)
    }
}

extension NavigationModel {
    
    func setNavigation(to navigation: Navigation?) {
        
        navigationSubject.send(navigation)
    }
}
