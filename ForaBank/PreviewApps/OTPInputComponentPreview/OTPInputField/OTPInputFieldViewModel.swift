//
//  OTPFieldViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import OTPInputComponent
import RxViewModel

typealias OTPFieldViewModel = RxViewModel<OTPFieldState, OTPFieldEvent, OTPFieldEffect>

extension OTPFieldViewModel {
    
    func edit(_ text: String) {
        
        self.event(.edit(text))
    }
}
