//
//  VerificationCodeData.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 07.11.2022.
//

import Foundation

struct VerificationCodeData: Codable, Equatable {
    
    let otp: String?
    let resendOTPCount: Int
}
