//
//  OpenAccountPrepareData.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 15.06.2022.
//

struct OpenAccountPrepareData: Decodable, Equatable {

    let otpLength: Int
    let otpResendTime: Int
    let resendOTPCount: Int

    enum CodingKeys: String, CodingKey {

        case otpLength = "OTPLength"
        case otpResendTime = "OTPResendTime"
        case resendOTPCount = "resendOTPCount"
    }
}
