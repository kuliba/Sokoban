//
//  RootViewModelFactory+makeCloseAccountSpinnerViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 20.03.2025.
//

extension RootViewModelFactory {
    
    func makeCloseAccountSpinnerViewModel(
        _ model: Model,
        _ flag: ProcessingFlag,
        _ productData: ProductData
    )  -> CloseAccountSpinnerView.ViewModel? {
        
        return .init(
            model,
            productData: productData,
            successViewModelFactory: makeSuccessViewModelFactory(flag)
        )
    }
}
