//
//  QRNavigation.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

public enum QRNavigation<Payments, QRFailure> {
    
    case payments(Node<Payments>)
    case qrFailure(Node<QRFailure>)
}
