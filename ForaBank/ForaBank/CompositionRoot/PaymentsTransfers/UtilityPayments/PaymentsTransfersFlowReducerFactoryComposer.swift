//
//  PaymentsTransfersFlowReducerFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

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
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func compose() -> Factory {
        
        return .init(
            makeUtilityPrepaymentState: makeUtilityPrepaymentState,
            makeUtilityPaymentState: makeUtilityPaymentState,
            makePaymentsViewModel: makePayByInstructionsViewModel
        )
    }
}

extension PaymentsTransfersFlowReducerFactoryComposer {
    
    typealias MicroServices = PrepaymentPickerMicroServices<UtilityPaymentOperator>
    
    typealias MakeTransactionViewModel = (AnywayTransactionState) -> AnywayTransactionViewModel
    
    typealias Factory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias UtilityPaymentViewModel = ObservingAnywayTransactionViewModel
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
    
    typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<PaymentsTransfersFlowReducerFactoryComposer.LastPayment, PaymentsTransfersFlowReducerFactoryComposer.Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias UtilityPrepaymentPayload = UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    typealias UtilityPrepaymentReducer = PrepaymentPickerReducer<UtilityPaymentLastPayment, UtilityPaymentOperator>
    typealias UtilityPrepaymentEffectHandler = PrepaymentPickerEffectHandler<UtilityPaymentOperator>
}

private extension PaymentsTransfersFlowReducerFactoryComposer {
    
    func makeUtilityPaymentState(
        payload: Factory.MakeUtilityPaymentStatePayload,
        notify: @escaping (PaymentStateProjection) -> Void
    ) -> UtilityServicePaymentFlowState<UtilityPaymentViewModel> {
        
        let observable = makeTransactionViewModel(payload.transaction)
        let viewModel = UtilityPaymentViewModel(
            observable: observable,
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

private extension PaymentsTransfersFlowReducerFactory.MakeUtilityPaymentStatePayload
where LastPayment == UtilityPaymentLastPayment,
      UtilityService == ForaBank.UtilityService {
    
    var transaction: AnywayTransactionState {
                
#warning("hardcoded `isValid: true` and `status: nil`")
        return .init(
            payment: .init(
                payment: .empty(puref).update(with: response, and: outline),
                staged: .init(),
                outline: outline
            ),
            isValid: true,
            status: nil
        )
    }
    
    private var outline: AnywayPaymentOutline {
        
        switch select {
        case let .lastPayment(lastPayment):
            return lastPayment.outline
            
        case .operator, .service:
            return .empty
        }
    }
    
    private var puref: AnywayPaymentDomain.AnywayPayment.Puref {
        
        switch select {
        case let .lastPayment(lastPayment):
            return .init(lastPayment.puref)
            
        case let .operator(`operator`):
            #warning("need operator puref? or wrong type is used here - puref should be extracted from select lastPayment or service? - like in StartAnywayPaymentPayload")
            fatalError()
            
        case let .service(utilityService, _):
            return .init(utilityService.puref)
        }
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

private extension AnywayPaymentOutline {
    
    static let empty: Self = .init(core: nil, fields: [:])
}

private extension UtilityPaymentLastPayment {
    
    var outline: AnywayPaymentOutline {
        
#warning("FIXME - replace hardcoded with data from LastPayment")
        return .empty
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
        _ previous: AnywayTransactionState,
        _ current: AnywayTransactionState
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
