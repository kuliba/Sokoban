//
//  ContentViewModelFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

struct ContentViewModelFactory {
    
    let makeTransactionViewModel: MakeTransactionViewModel
}

extension ContentViewModelFactory {
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> TransactionViewModel
    typealias Observe = (AnywayTransactionState) -> Void
    typealias TransactionViewModel = ObservingCachedAnywayTransactionViewModel
}

extension ContentViewModelFactory {
    
    static func `default`() -> Self {
        
        .init(
            makeTransactionViewModel: { initialState, observe in
                
                let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
                    nanoServices: .stubbed(with: .init(
                        getDetailsResult: "Operation Detail",
                        makeTransferResult: .init(
                            status: .completed,
                            detailID: 54321
                        )
                    ))
                )
                
                let composer = AnywayTransactionViewModelComposer(
                    microServices: .stubbed(with: .init(
                        initiatePayment: .success(.preview),
                        makePayment: .init(
                            status: .completed,
                            info: .details("Operation Detail")
                        ),
                        processPayment: .success(.preview))
                    )
                )
                
                let observable = composer.compose(initialState: initialState)
                
                return .init(observable: observable, observe: observe)
            }
        )
    }
}
