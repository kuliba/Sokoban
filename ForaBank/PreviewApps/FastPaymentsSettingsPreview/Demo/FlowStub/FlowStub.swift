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
    let changeConsentList: ConsentListRxEffectHandler.ChangeConsentListResponse
    let createContract: ContractEffectHandler.CreateContractResult
    let getC2BSub: FastPaymentsSettingsEffectHandler.GetC2BSubResult
    let getSettings: UserPaymentSettingsResult
    let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefaultResponse
    let updateContract: ContractEffectHandler.UpdateContractResult
    let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProductResponse
    let initiateOTP: CountdownEffectHandler.InitiateOTPResult
    let submitOTP: OTPFieldEffectHandler.SubmitOTPResult
}
