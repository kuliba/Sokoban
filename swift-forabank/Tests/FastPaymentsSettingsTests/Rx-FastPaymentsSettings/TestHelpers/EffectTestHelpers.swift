//
//  EffectTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings

func anyEffectProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> FastPaymentsSettingsEffect.Contract.ProductID {
    
    .init(rawValue)
}

func activateContract(
    _ contract: FastPaymentsSettingsEffect.Contract.TargetContract
) -> FastPaymentsSettingsEffect {
    
    .contract(.activateContract(contract))
}

func createContract(
    _ productID: FastPaymentsSettingsEffect.Contract.ProductID
) -> FastPaymentsSettingsEffect {
    
    .contract(.createContract(productID))
}

func deactivateContract(
    _ contract: FastPaymentsSettingsEffect.Contract.TargetContract
) -> FastPaymentsSettingsEffect {
    
    .contract(.deactivateContract(contract))
}

func fastPaymentsSettingsEffectTargetContract(
    contractID: FastPaymentsSettingsEffect.ContractCore.ContractID = .init(generateRandom11DigitNumber()),
    product: Product = makeProduct(),
    targetStatus: ContractEffectHandler.UpdateContractPayload.TargetStatus = .active
) -> FastPaymentsSettingsEffect.Contract.TargetContract {
    
    .init(
        core: .init(
            contractID: contractID,
            product: product
        ),
        targetStatus: targetStatus)
}

func makeCore(
    _ details: UserPaymentSettings.ContractDetails,
    _ product: Product
) -> FastPaymentsSettingsEffect.ContractCore {
    
    .init(
        contractID: .init(details.paymentContract.id.rawValue),
        product: product
    )
}

func updateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    product: Product = makeProduct()
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        product: product
    )
}
