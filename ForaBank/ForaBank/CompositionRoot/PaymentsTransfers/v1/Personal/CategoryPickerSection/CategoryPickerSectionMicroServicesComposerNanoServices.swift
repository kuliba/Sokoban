//
//  CategoryPickerSectionMicroServicesComposerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

struct CategoryPickerSectionMicroServicesComposerNanoServices {
    
    let makeMobile: MakeMobile
    let makeQR: MakeQR
    let makeQRNavigation: MakeQRNavigation
    let makeStandard: MakeStandard
    let makeTax: MakeTax
    let makeTransport: MakeTransport
    
    typealias MakeMobile = () -> ClosePaymentsViewModelWrapper
    typealias MakeQR = () -> QRScannerModel
    
    typealias MakeQRNavigationCompletion = (QRNavigation) -> Void
    typealias Notify = QRNavigationComposer.Notify
    typealias MakeQRNavigation = (QRModelResult, @escaping Notify, @escaping MakeQRNavigationCompletion) -> Void
    
    typealias MakeStandard = (ServiceCategory, @escaping (StandardSelectedCategoryDestination) -> Void) -> Void
    typealias MakeTax = () -> ClosePaymentsViewModelWrapper
    typealias MakeTransport = () -> TransportPaymentsViewModel?
}
