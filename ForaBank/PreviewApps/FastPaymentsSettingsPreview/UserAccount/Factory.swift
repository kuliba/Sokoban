//
//  Factory.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation
import OTPInputComponent

struct Factory {
    
    let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
    let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
}

extension Factory {
    
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
    typealias MakeTimedOTPInputViewModel = (AnySchedulerOfDispatchQueue) -> TimedOTPInputViewModel
}
