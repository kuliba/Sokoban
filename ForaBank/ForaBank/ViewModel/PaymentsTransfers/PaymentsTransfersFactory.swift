//
//  PaymentsTransfersFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersFactory {
    
    let makeUtilitiesViewModel: MakeUtilitiesViewModel
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makeTemplatesListViewModel: MakeTemplatesListViewModel
}

extension PaymentsTransfersFactory {
    
    struct MakeUtilitiesPayload {
        
        let type: PTSectionPaymentsView.ViewModel.PaymentsType
        let navLeadingAction: () -> Void
        let navTrailingAction: () -> Void
        let addCompany: () -> Void
        let requisites: () -> Void
    }
    
    enum UtilitiesVM {
        
        case legacy(PaymentsServicesViewModel)
        case utilities(UtilitiesViewModel)
    }
    
    typealias MakeUtilitiesViewModel = (MakeUtilitiesPayload, @escaping (UtilitiesVM) -> Void) -> Void
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    typealias DismissAction = () -> Void
    typealias MakeTemplatesListViewModel = (@escaping DismissAction) -> TemplatesListViewModel
}

extension PaymentsTransfersFactory {
    
    static let preview: Self = {
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersNavigationStateManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .init(
                alertReduce: AlertReducer(productAlertsViewModel: .default).reduce,
                bottomSheetReduce: BottomSheetReducer().reduce,
                handleEffect: ProductNavigationStateEffectHandler().handleEffect
            )
        )
        return .init(
            makeUtilitiesViewModel: { _,_ in },
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete }
        )
    }()
}
