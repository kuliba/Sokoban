//
//  PaymentsTransfersFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import Foundation
import OperatorsListComponents
import PrePaymentPicker

#warning("replace with type from module")
final class UtilitiesViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let loadOperators: LoadOperators
    
    init(
        initialState: State,
        loadOperators: @escaping LoadOperators
    ) {
        self.state = initialState
        self.loadOperators = loadOperators
    }
    
    // MARK: - types
    
    typealias State = PrePaymentOptionsState<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator>
    
    struct Payload {}
    
    typealias LoadOperatorsCompletion = ([OperatorsListComponents.Operator]) -> Void
    typealias LoadOperators = (Payload, @escaping LoadOperatorsCompletion) -> Void
}

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
            cvvPINServicesClient: HappyCVVPINServicesClient()
        )
        return .init(
            makeUtilitiesViewModel: { _,_ in },
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete }
        )
    }()
}
