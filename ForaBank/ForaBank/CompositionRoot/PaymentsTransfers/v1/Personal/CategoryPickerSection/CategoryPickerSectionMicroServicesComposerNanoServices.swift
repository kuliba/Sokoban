//
//  CategoryPickerSectionMicroServicesComposerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

struct CategoryPickerSectionMicroServicesComposerNanoServices {
    
    let makeMobile: MakeMobile
    let makeQR: MakeQR
    let makeStandard: MakeStandard
    let makeTax: MakeTax
    let makeTransport: MakeTransport
    
    typealias MakeMobile = () -> ClosePaymentsViewModelWrapper
    typealias MakeQR = () -> QRModel
    typealias MakeStandard = (ServiceCategory, @escaping (StandardSelectedCategoryDestination) -> Void) -> Void
    typealias MakeTax = () -> ClosePaymentsViewModelWrapper
    typealias MakeTransport = () -> TransportPaymentsViewModel?
}
