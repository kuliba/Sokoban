//
//  CachedAnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import PaymentComponents

final class CachedAnywayTransactionViewModelComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    private let makeTransactionViewModel: MakeTransactionViewModel

    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts,
        makeTransactionViewModel: @escaping MakeTransactionViewModel
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
        self.makeTransactionViewModel = makeTransactionViewModel
    }
    
   typealias CurrencyOfProduct = (ProductSelect.Product) -> String
   typealias GetProducts = () -> [ProductSelect.Product]
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> AnywayTransactionViewModel
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
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
            statePublisher: transactionViewModel.$state.removeDuplicates().eraseToAnyPublisher(),
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
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
