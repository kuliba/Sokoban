//
//  QRNavigation.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

public enum QRNavigation<MixedPicker, MultiplePicker, Payments, QRFailure> {
    
    case mixedPicker(Node<MixedPicker>)
    case multiplePicker(Node<MultiplePicker>)
    case payments(Node<Payments>)
    case qrFailure(Node<QRFailure>)
}
