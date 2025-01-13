//
//  QRParsingResult.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Foundation

enum QRParsingResult {
    
    case sberQR(URL)
    case error(String)
}
