//
//  EventTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings

func activateContract(
) -> FastPaymentsSettingsEvent {
    
    .contract(.activateContract)
}

func deactivateContract(
) -> FastPaymentsSettingsEvent {
    
    .contract(.deactivateContract)
}

func prepareSetBankDefault(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.prepareSetBankDefault)
}

func setBankDefault(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefault)
}

func setBankDefaultPreparedSuccess(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultPrepared(nil))
}

func setBankDefaultPreparedConnectivityError(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultPrepared(.connectivityError))
}

func setBankDefaultPreparedServerError(
    _ message: String = anyMessage()
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultPrepared(.serverError(message)))
}

func selectProduct(
    _ product: Product = makeProduct()
) -> FastPaymentsSettingsEvent {
    
    .products(.selectProduct(product.id))
}

func toggleProducts(
) -> FastPaymentsSettingsEvent {
    
    .products(.toggleProducts)
}

func updateContractConnectivityError(
) -> FastPaymentsSettingsEvent {
    
    .contract(.updateContract(.failure(.connectivityError)))
}

func updateContractServerError(
    _ message: String = anyMessage()
) -> FastPaymentsSettingsEvent {
    
    .contract(.updateContract(.failure(.serverError(message))))
}

func updateContractSuccess(
    _ contract: UserPaymentSettings.PaymentContract = paymentContract()
) -> FastPaymentsSettingsEvent {
    
    .contract(.updateContract(.success(contract)))
}

func updateProductSuccess(
    _ product: Product = makeProduct()
) -> FastPaymentsSettingsEvent {
    
    .products(.updateProduct(.success(product.id)))
}

func updateProductConnectivityError(
) -> FastPaymentsSettingsEvent {
    
    .products(.updateProduct(.failure(.connectivityError)))
}

func updateProductServerError(
    _ message: String = anyMessage()
) -> FastPaymentsSettingsEvent {
    
    .products(.updateProduct(.failure(.serverError(message))))
}

func updateProductSuccess() -> FastPaymentsSettingsEvent {
    
    .products(.updateProduct(.success(makeProduct().id)))
}
