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

func setBankDefaultSuccess(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultResult(.success))
}

func setBankDefaultIncorrectOTP(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultResult(.incorrectOTP("Введен некорректный код. Попробуйте еще раз")))
}

func setBankDefaultConnectivityError(
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultResult(.serviceFailure(.connectivityError)))
}

func setBankDefaultServerError(
    _ message: String = anyMessage()
) -> FastPaymentsSettingsEvent {
    
    .bankDefault(.setBankDefaultResult(.serviceFailure(.serverError(message))))
}

func makeSelectableProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> SelectableProductID {
    
    .account(.init(rawValue))
}

func selectProduct(
    _ product: Product = makeProduct()
) -> FastPaymentsSettingsEvent {
    
    .products(.selectProduct(product.selectableProductID))
}

func select(
    _ selectableProductID: SelectableProductID = makeSelectableProductID()
) -> FastPaymentsSettingsEvent {
    
    .products(.selectProduct(selectableProductID))
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
    
    .products(.updateProduct(.success(product.selectableProductID)))
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
    
    .products(.updateProduct(.success(makeProduct().selectableProductID)))
}
