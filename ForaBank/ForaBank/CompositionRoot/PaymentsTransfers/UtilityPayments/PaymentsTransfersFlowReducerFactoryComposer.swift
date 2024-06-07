//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RxViewModel
import UtilityServicePrepaymentCore

final class PaymentsTransfersFlowReducerFactoryComposer {
    
    private let model: Model
    private let observeLast: Int
    private let microServices: MicroServices
    private let makeTransactionViewModel: MakeTransactionViewModel
    
    init(
        model: Model,
        observeLast: Int,
        microServices: MicroServices,
        makeTransactionViewModel: @escaping MakeTransactionViewModel
    ) {
        self.model = model
        self.observeLast = observeLast
        self.microServices = microServices
        self.makeTransactionViewModel = makeTransactionViewModel
    }
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
    
    typealias MakeTransactionViewModel = (AnywayTransactionState) -> AnywayTransactionViewModel
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func compose() -> Factory {
        
        return .init(
            makeUtilityPrepaymentState: makeUtilityPrepaymentState,
            makeUtilityPaymentState: makeUtilityPaymentState,
            makePaymentsViewModel: makePayByInstructionsViewModel
        )
    }
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel>
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentViewModel
    typealias UtilityPaymentViewModel = ObservingCachedAnywayTransactionViewModel
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPrepaymentState(
        payload: UtilityPrepaymentPayload
    ) -> UtilityFlowState {
        
        let reducer = UtilityPrepaymentReducer(observeLast: observeLast)
        
        let effectHandler = UtilityPrepaymentEffectHandler(
            microServices: microServices
        )
        
        let viewModel = UtilityPrepaymentViewModel(
            initialState: .init(
                lastPayments: payload.lastPayments,
                operators: payload.operators,
                searchText: ""
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        return .init(content: viewModel)
    }
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, UtilityService, Content, UtilityPaymentViewModel>
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias UtilityPrepaymentPayload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPaymentState(
        transactionState: AnywayTransactionState,
        notify: @escaping (PaymentStateProjection) -> Void
    ) -> UtilityServicePaymentFlowState<UtilityPaymentViewModel> {
        
        let transactionViewModel = makeTransactionViewModel(transactionState)
        
        let mapAnywayElement: (AnywayElement) -> AnywayElement = { $0 }
        
        typealias Updater = CachedAnywayTransactionUpdater<DocumentStatus, AnywayElement, OperationDetailID, OperationDetails>
        let updater = Updater(map: mapAnywayElement)
        
        typealias Reducer = CachedAnywayTransactionReducer<AnywayTransactionState, CachedTransactionState, AnywayTransactionEvent>
        let reducer = Reducer(update: updater.update(_:with:))
        
        let effectHandler = CachedAnywayTransactionEffectHandler(
            statePublisher: transactionViewModel.$state.eraseToAnyPublisher(),
            event: transactionViewModel.event(_:)
        )
        
        let initialState = CachedTransactionState(
            payment: .init(transactionState.payment, using: mapAnywayElement),
            isValid: transactionState.isValid,
            status: transactionState.status
        )
        let cachedTransactionViewModel = RxViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        let viewModel = UtilityPaymentViewModel(
            observable: cachedTransactionViewModel,
            observe: { PaymentStateProjection($0, $1).map(notify) }
        )
        
        return .init(viewModel: viewModel)
    }
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makePayByInstructionsViewModel(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(model, service: .requisites, closeAction: closeAction)
    }
}

private extension AnywayPaymentDomain.AnywayPayment {
    
    static func empty(
        _ puref: Puref
    ) -> Self {
        
        return .init(
            elements: [],
            infoMessage: nil,
            isFinalStep: false,
            isFraudSuspected: false,
            puref: puref
        )
    }
}

#warning("looks like a better way would be to change: typealias PaymentStateProjection = TransactionStatus<...>")
enum PaymentStateProjection: Equatable {
    case completed
    case errorMessage(String)
    case fraud(Fraud)
}

extension PaymentStateProjection {
    
    init?(
        _ previous: CachedTransactionState,
        _ current: CachedTransactionState
    ) {
#warning("previous is ignored")
        switch current.status {
        case .fraudSuspected:
            self = .fraud(.init())
            
        case .result:
            self = .completed
            
        case let .serverError(errorMessage):
            self = .errorMessage(errorMessage)
            
        default:
            return nil
        }
    }
}
