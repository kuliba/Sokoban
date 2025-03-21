//
//  SuccessViewModelFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 18.03.2025.
//


struct SuccessViewModelFactory {
    
    typealias MakeCloseAccountPaymentsSuccessViewModel = (CloseAccountPayload.Payload) -> PaymentsSuccessViewModel?
    
    let makeCloseAccountPaymentsSuccessViewModel: MakeCloseAccountPaymentsSuccessViewModel
}

