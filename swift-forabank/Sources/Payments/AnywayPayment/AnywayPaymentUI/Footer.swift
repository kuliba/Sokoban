//
//  Footer.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

public enum Footer<AmountViewModel> {
    
    case continueButton(() -> Void)
    case amount(AmountViewModel)
}
