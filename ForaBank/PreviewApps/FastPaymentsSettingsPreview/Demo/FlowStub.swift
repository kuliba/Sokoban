//
//  FlowStub.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings

struct FlowStub {
    
    let getProducts: [Product]
    let createContract: FastPaymentsSettingsEffectHandler.CreateContractResponse
    let getSettings: UserPaymentSettings
    let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefaultResponse
    let updateContract: FastPaymentsSettingsEffectHandler.UpdateContractResponse
    let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProductResponse
}
