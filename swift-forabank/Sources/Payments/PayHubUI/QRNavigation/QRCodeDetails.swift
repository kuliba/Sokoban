//
//  QRCodeDetails.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

public enum QRCodeDetails<QRCode> {
    
    case qrCode(QRCode)
    case missingINN(QRCode)
}

extension QRCodeDetails: Equatable where QRCode: Equatable {}
