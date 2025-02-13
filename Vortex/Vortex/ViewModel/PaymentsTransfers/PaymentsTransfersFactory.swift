//
//  PaymentsTransfersFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.05.2024.
//

import CalendarUI
import Combine
import PayHubUI
import SwiftUI
import VortexTools

struct PaymentsTransfersFactory {
    
    let makeAlertViewModels: MakeAlertViewModels
    let makePaymentProviderPickerFlowModel: MakePaymentProviderPickerFlowModel
    let makePaymentProviderServicePickerFlowModel: MakePaymentProviderServicePickerFlowModel
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makeSections: MakePaymentsTransfersSections
    let makeServicePaymentBinder: MakeServicePaymentBinder
    let makeTemplates: MakeTemplates
    let makeUtilitiesViewModel: MakeUtilitiesViewModel
    let makePaymentsTransfers: MakePaymentsTransfers
}

extension PaymentsTransfersFactory {
    
    struct MakeAlertViewModels {
        
        let dataUpdateFailure: MakeOptionalAlertViewModel
        let disableForCorporateCard: MakeAlertViewModel
    }
    
    struct MakeUtilitiesPayload {
        
        let type: PTSectionPaymentsView.ViewModel.PaymentsType
        let navLeadingAction: () -> Void
        let navTrailingAction: () -> Void
        let addCompany: () -> Void
        let requisites: () -> Void
    }
    
    enum UtilitiesVM {
        
        case legacy(PaymentsServicesViewModel)
        case utilities
    }
    
    typealias MakeUtilitiesViewModel = (MakeUtilitiesPayload, @escaping (UtilitiesVM) -> Void) -> Void
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    
    typealias DismissAction = () -> Void
    typealias TemplatesNode = Node<Templates>
    typealias Templates = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>
    typealias MakeTemplates = (@escaping DismissAction) -> Templates?
    
    typealias MakePaymentsTransfersSections = () -> [PaymentsTransfersSectionViewModel]
    typealias MakeOptionalAlertViewModel = (@escaping DismissAction) -> Alert.ViewModel?
    typealias MakeAlertViewModel = (@escaping DismissAction) -> Alert.ViewModel
    
    typealias MakePaymentProviderPickerFlowModel = (MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping) -> SegmentedPaymentProviderPickerFlowModel
    
    typealias MakePaymentProviderServicePickerFlowModel = (PaymentProviderServicePickerPayload) -> AnywayServicePickerFlowModel
    
    typealias MakeServicePaymentBinder = (AnywayTransactionState.Transaction, ServicePaymentFlowState) -> ServicePaymentBinder
    
    typealias MakePaymentsTransfers = () -> PaymentsTransfersSwitcherProtocol

}

extension PaymentsTransfersFactory {
    
    static let preview: Self = {
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            makeTemplates: { _ in .sampleComplete },
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(), 
            landingServices: .empty(),
            productProfileServices: .preview,
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: ProductProfileFlowManager.preview,
            makeCardGuardianPanel: ProductProfileViewModelFactory.makeCardGuardianPanelPreview,
            makeRepeatPaymentNavigation: { _,_,_,_  in .none },
            makeSubscriptionsViewModel: { _,_ in .preview },
            updateInfoStatusFlag: .inactive,
            makePaymentProviderPickerFlowModel: SegmentedPaymentProviderPickerFlowModel.preview,
            makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
            makeServicePaymentBinder: ServicePaymentBinder.preview,
            makeOpenNewProductButtons: { _ in [] },
            makeOrderCardViewModel: { /*TODO:  implement preview*/ },
            makePaymentsTransfers: { PreviewPaymentsTransfersSwitcher() }
        )
        
        return .init(
            makeAlertViewModels: .default,
            makePaymentProviderPickerFlowModel: SegmentedPaymentProviderPickerFlowModel.preview,
            makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
            makeProductProfileViewModel: productProfileViewModel,
            makeSections: { Model.emptyMock.makeSections(flag: .inactive) },
            makeServicePaymentBinder: ServicePaymentBinder.preview,
            makeTemplates: { _ in .sampleComplete },
            makeUtilitiesViewModel: { _,_ in },
            makePaymentsTransfers: { PreviewPaymentsTransfersSwitcher() }
        )
    }()
}

final class PreviewPaymentsTransfersSwitcher: PaymentsTransfersSwitcherProtocol {
    
    var hasDestination: AnyPublisher<Bool, Never> { Empty().eraseToAnyPublisher() }
}

extension PaymentsTransfersPersonalDomain.Binder {
    
    static var preview: Self {
        
        let content = PaymentsTransfersPersonalContent(categoryPicker: PreviewCategoryPicker(), operationPicker: PreviewOperationPicker(), transfers: PreviewTransfers(), reload: {})
        
        return .init(
            content: content,
            flow: .init(
                initialState: .init(),
                reduce: { state, _ in (state, nil) },
                handleEffect: { _,_ in }
            ),
            bind: { _,_ in [] }
        )
    }
}

private final class PreviewCategoryPicker: CategoryPicker {}

private final class PreviewOperationPicker: OperationPicker {}

private final class PreviewTransfers: TransfersPicker {}

extension PaymentsTransfersFactory.MakeAlertViewModels {
    
    static let `default`: Self = .init(
        dataUpdateFailure: { _ in .techError {} },
        disableForCorporateCard: { .disableForCorporateCard(primaryAction: $0) }
    )
}

extension SegmentedPaymentProviderPickerFlowModel {
    
    static func preview(
        mix: MultiElementArray<SegmentedOperatorProvider>,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) -> SegmentedPaymentProviderPickerFlowModel {
        
        return .init(
            initialState: .init(
                content: .init(
                        segments: [],
                        qrCode: qrCode,
                        qrMapping: qrMapping
                )
            ),
            factory: .init(
                makePayByInstructionsViewModel: { _,_ in fatalError() },
                makePaymentsViewModel: { _,_,_ in fatalError() },
                makeServicePickerFlowModel: { _ in fatalError() }),
            scheduler: .main
        )
    }
}

extension PaymentProviderServicePickerFlowModel {
    
    static func preview(
        payload: PaymentProviderServicePickerPayload
    ) -> Self {
        
        return .init(
            initialState: .init(
                content: .init(
                    initialState: .init(payload: payload),
                    reduce: { state, _ in (state, nil) },
                    handleEffect: { _,_ in }
                )
            ),
            factory: .init(
                makeServicePaymentBinder: { .preview(transaction: $0) }
            ),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}

extension ServicePaymentBinder {
    
    static func preview(
        transaction: AnywayTransactionState.Transaction,
        initialFlowState: ServicePaymentFlowState = .none
    ) -> Self {
        
        return .init(
            content: .init(
                transaction: transaction,
                mapToModel: { _ in { .field(.init(name: "\($0)", title: "Field Title", value: "FieldValue", icon: nil)) }},
                footer: .init(
                    initialState: .init(
                        amount: 0,
                        button: .init(
                            title: "Button Title",
                            state: .active
                        ),
                        style: .amount
                    ),
                    currencySymbol: "₽"
                ),
                reduce: { state, _ in (state, nil) },
                handleEffect: { _,_ in }
            ),
            flow: .init(
                initialState: initialFlowState,
                reduce: { state, _ in (state, nil) },
                handleEffect: { _,_ in }
            ),
            scheduler: .main
        )
    }
}

extension TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel> {
    
    static var sampleComplete: Self {
        
        let reducer = TemplatesListFlowReducer<TemplatesListViewModel, AnywayFlowModel>()
        let microServices = TemplatesListFlowEffectHandlerMicroServices<PaymentsViewModel, AnywayFlowModel>(
            makePayment: { payload, completion in
                
                let (template, close) = payload
                
                completion(.success(.legacy(.init(
                    source: .template(template.id),
                    model: .emptyMock,
                    closeAction: close
                ))))
            }
        )
        let effectHandler = TemplatesListFlowEffectHandler<AnywayFlowModel>(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(content: .sampleComplete),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .main
        )
    }
}
