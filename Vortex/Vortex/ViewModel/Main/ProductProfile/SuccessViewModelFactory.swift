//
//  SuccessViewModelFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 18.03.2025.
//


struct SuccessViewModelFactory {
    
    typealias MakeCloseAccountPaymentsSuccessViewModel = (PaymentsSuccessViewModel.Mode) -> PaymentsSuccessViewModel?
    
    let makeCloseAccountPaymentsSuccessViewModel: MakeCloseAccountPaymentsSuccessViewModel
}

