//
//  FlowStub.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent

struct FlowStub {
    
    let getProducts: [Product]
    let createContract: ContractEffectHandler.CreateContractResponse
    let getSettings: UserPaymentSettings
    let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefaultResponse
    let updateContract: ContractEffectHandler.UpdateContractResponse
    let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProductResponse
    let initiateOTP: CountdownEffectHandler.InitiateOTPResult
    let submitOTP: OTPFieldEffectHandler.SubmitOTPResult
}
