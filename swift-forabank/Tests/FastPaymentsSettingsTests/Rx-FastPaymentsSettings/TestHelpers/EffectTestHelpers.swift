//
//  EffectTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings

func anyEffectProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> ContractEffect.ProductID {
    
    .init(rawValue)
}

func activateContract(
    _ contract: ContractEffect.TargetContract
) -> FastPaymentsSettingsEffect {
    
    .contract(.activateContract(contract))
}

func createContract(
    _ productID: ContractEffect.ProductID
) -> FastPaymentsSettingsEffect {
    
    .contract(.createContract(productID))
}

func deactivateContract(
    _ contract: ContractEffect.TargetContract
) -> FastPaymentsSettingsEffect {
    
    .contract(.deactivateContract(contract))
}

func fastPaymentsSettingsEffectTargetContract(
    contractID: FastPaymentsSettingsEffect.ContractCore.ContractID = .init(generateRandom11DigitNumber()),
    product: Product = makeProduct(),
    targetStatus: ContractEffectHandler.UpdateContractPayload.TargetStatus = .active
) -> ContractEffect.TargetContract {
    
    .init(
        core: .init(
            contractID: contractID,
            productID: product.id
        ),
        targetStatus: targetStatus)
}

func makeCore(
    _ details: UserPaymentSettings.ContractDetails,
    _ product: Product
) -> FastPaymentsSettingsEffect.ContractCore {
    
    .init(
        contractID: .init(details.paymentContract.id.rawValue),
        productID: product.id
    )
}

func updateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    product: Product = makeProduct()
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        productID: product.id
    )
}
