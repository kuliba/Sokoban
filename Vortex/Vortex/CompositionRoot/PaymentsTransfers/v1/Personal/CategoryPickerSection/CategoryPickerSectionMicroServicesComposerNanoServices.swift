//
//  CategoryPickerSectionMicroServicesComposerNanoServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.09.2024.
//

struct CategoryPickerSectionMicroServicesComposerNanoServices {
    
    let makeMobile: MakeMobile
    let makeStandard: MakeStandard
    let makeTax: MakeTax
    let makeTransport: MakeTransport
    
    typealias MakeMobile = () -> ClosePaymentsViewModelWrapper
    typealias Standard = CategoryPickerViewDomain.Destination.Standard
    typealias MakeStandard = (ServiceCategory, @escaping (Standard) -> Void) -> Void
    typealias MakeTax = () -> ClosePaymentsViewModelWrapper
    typealias MakeTransport = () -> TransportPaymentsViewModel?
}
