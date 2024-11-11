//
//  QRResult.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation

public enum QRResult<QRCode, Mapped> {
    
    case c2bSubscribeURL(URL)
    case c2bURL(URL)
    case failure(QRCode)
    case mapped(Mapped)
    case sberQR(URL)
    case url(URL)
    case unknown
}

extension QRResult: Equatable where QRCode: Equatable, Mapped: Equatable {}
