//
//  Model+authLoginViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.11.2023.
//

extension ModelAuthLoginViewModelFactory: AuthLoginViewModelFactory {}

extension Model {
    
    func authLoginViewModelFactory(
        rootActions: RootViewModel.RootActions
    ) -> AuthLoginViewModelFactory {
        
        ModelAuthLoginViewModelFactory(
            model: self,
            rootActions: rootActions
        )
    }
}
