//
//  EffectTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings

func activateContract(
    _ contract: ContractEffect.TargetContract
) -> FastPaymentsSettingsEffect {
    
    .contract(.activateContract(contract))
}

func createContract(
    _ product: Product
) -> FastPaymentsSettingsEffect {
    
    .contract(.createContract(product))
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
            selectableProductID: product.selectableProductID
        ),
        targetStatus: targetStatus)
}

func makeCore(
    _ details: UserPaymentSettings.Details,
    _ product: Product
) -> FastPaymentsSettingsEffect.ContractCore {
    
    .init(
        contractID: .init(details.paymentContract.id.rawValue),
        selectableProductID: product.selectableProductID
    )
}

func updateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    product: Product = makeProduct()
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        selectableProductID: product.selectableProductID
    )
}
