//
//  OTPInputViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import OTPInputComponent
import RxViewModel

typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

extension OTPInputViewModel {
    
    func edit(_ text: String) {
        
        self.event(.edit(text))
    }
}
