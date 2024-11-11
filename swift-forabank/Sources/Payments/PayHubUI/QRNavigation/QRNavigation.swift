//
//  QRNavigation.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

public enum QRNavigation<MixedPicker, MultiplePicker, OperatorModel, Payments, QRFailure, ServicePicker> {
    
    case mixedPicker(Node<MixedPicker>)
    case multiplePicker(Node<MultiplePicker>)
    case operatorModel(OperatorModel)
    case payments(Node<Payments>)
    case qrFailure(Node<QRFailure>)
    case servicePicker(Node<ServicePicker>)
}
