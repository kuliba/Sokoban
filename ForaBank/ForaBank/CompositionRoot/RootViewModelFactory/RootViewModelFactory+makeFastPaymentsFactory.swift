//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeFastPaymentsFactory() -> FastPaymentsFactory {
        
        return .init(
            fastPaymentsViewModel: .new({
                
                self.makeNewFastPaymentsViewModel()
            })
        )
    }
}
