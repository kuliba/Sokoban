//
//  CategoryPickerSectionMicroServicesComposerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

struct CategoryPickerSectionMicroServicesComposerNanoServices {
    
    let makeMobile: MakeMobile
    let makeTax: MakeTax
    let makeTransport: MakeTransport
    
    typealias MakeMobile = () -> ClosePaymentsViewModelWrapper
    typealias MakeTax = () -> ClosePaymentsViewModelWrapper
    typealias MakeTransport = () -> TransportPaymentsViewModel?
}
