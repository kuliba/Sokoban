//
//  CachedAnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import PaymentComponents

final class CachedAnywayTransactionViewModelComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    private let makeTransactionViewModel: MakeTransactionViewModel
    private let spinnerActions: SpinnerActions
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts,
        makeTransactionViewModel: @escaping MakeTransactionViewModel,
        spinnerActions: SpinnerActions
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
        self.makeTransactionViewModel = makeTransactionViewModel
        self.spinnerActions = spinnerActions
    }
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> AnywayTransactionViewModel
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    
    typealias SpinnerActions = RootViewModel.RootActions.Spinner?
}

extension CachedAnywayTransactionViewModelComposer {
    
    func makeCachedAnywayTransactionViewModel(
        transactionState: AnywayTransactionState,
        notify: @escaping (AnywayTransactionStatus?) -> Void
    ) -> CachedAnywayTransactionViewModel {
        
        let transactionViewModel = makeTransactionViewModel(
            transactionState,
            { _, state in
                
                // TODO: remove debug print
                print("notify: Transaction Status", state.status ?? "nil")
                notify(state.status)
            }
        )
        
        let mapper = AnywayElementModelMapper(
            event: { transactionViewModel.event(.payment($0)) },
            currencyOfProduct: currencyOfProduct,
            getProducts: getProducts
        )
        let mapAnywayElement = mapper.map(_:)
        
        typealias Updater = CachedAnywayTransactionUpdater<DocumentStatus, AnywayElementModel, OperationDetailID, OperationDetails>
        let updater = Updater(map: mapAnywayElement)
        
        typealias Reducer = CachedAnywayTransactionReducer<AnywayTransactionState, CachedTransactionState, AnywayTransactionEvent>
        let reducer = Reducer(update: updater.update(_:with:))
        
        let effectHandler = CachedAnywayTransactionEffectHandler(
            statePublisher: transactionViewModel.$state
                .removeDuplicates(by: hasNoSignificantDifference)
                .eraseToAnyPublisher(),
            event: transactionViewModel.event(_:)
        )
        
        let initialState = CachedTransactionState(
            context: .init(
                transactionState.context,
                using: mapAnywayElement
            ),
            isValid: transactionState.isValid,
            status: transactionState.status
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { effect, dispatch in
                
//                switch effect {
//                case .event(.continue):
//                    self.spinnerActions?.show()
//                    
//                    effectHandler.handleEffect(effect) {
//                        
//                        dispatch($0)
//                        self.spinnerActions?.hide()
//                    }
//                    
//                default:
                    effectHandler.handleEffect(effect, dispatch)
//                }
            }
        )
    }
}

/// Checks if two `AnywayTransactionState` instances have no significant differences.
/// - Parameters:
///   - one: The first `AnywayTransactionState` instance to compare.
///   - other: The second `AnywayTransactionState` instance to compare.
/// - Returns: `true` if there are no significant differences between the two instances; otherwise, `false`.
private func hasNoSignificantDifference(
    _ one: AnywayTransactionState,
    from other: AnywayTransactionState
) -> Bool {
    
    !hasSignificantDifference(one, from: other)
}

/// Checks if two `AnywayTransactionState` instances have significant differences.
/// - Parameters:
///   - one: The first `AnywayTransactionState` instance to compare.
///   - other: The second `AnywayTransactionState` instance to compare.
/// - Returns: `true` if there are significant differences between the two instances; otherwise, `false`.
private func hasSignificantDifference(
    _ one: AnywayTransactionState,
    from other: AnywayTransactionState
) -> Bool {
    
    guard one.isValid == other.isValid,
          one.status == other.status
    else { return true }
    
    return hasSignificantDifference(one.context, from: other.context)
}

/// Checks if two `AnywayPaymentContext` instances have significant differences.
/// - Parameters:
///   - one: The first `AnywayPaymentContext` instance to compare.
///   - other: The second `AnywayPaymentContext` instance to compare.
/// - Returns: `true` if there are significant differences between the two instances; otherwise, `false`.
private func hasSignificantDifference(
    _ one: AnywayPaymentContext,
    from other: AnywayPaymentContext
) -> Bool {
    
    guard one.staged == other.staged,
          one.outline == other.outline,
          one.shouldRestart == other.shouldRestart
    else { return true }
    
    return hasSignificantDifference(one.payment, from: other.payment)
}

/// Checks if two `AnywayPaymentDomain.AnywayPayment` instances have significant differences.
/// This function compares the key properties of two `AnywayPaymentDomain.AnywayPayment` instances to determine
/// if there are any significant differences between them.
///
/// The `setOfElementIDs` property, which is derived from the IDs of the payment elements, plays a crucial role
/// in determining significant differences between the two instances. If this set of IDs differs, the function
/// will return `true` indicating a significant difference.
///
/// - Parameters:
///   - one: The first `AnywayPaymentDomain.AnywayPayment` instance to compare.
///   - other: The second `AnywayPaymentDomain.AnywayPayment` instance to compare.
/// - Returns: `true` if there are significant differences between the two instances; otherwise, `false`.
private func hasSignificantDifference(
    _ one: AnywayPaymentDomain.AnywayPayment,
    from other: AnywayPaymentDomain.AnywayPayment
) -> Bool {
    
    guard one.footer == other.footer,
          one.infoMessage == other.infoMessage,
          one.isFinalStep == other.isFinalStep,
          one.isFraudSuspected == other.isFraudSuspected
    else { return true }
    
    return one.setOfElementIDs != other.setOfElementIDs
}

private extension AnywayPaymentDomain.AnywayPayment {
    
    var setOfElementIDs: Set<AnywayElement.ID> { .init(elements.map(\.id)) }
}
