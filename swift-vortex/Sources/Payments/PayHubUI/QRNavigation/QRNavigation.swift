//
//  QRNavigation.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Foundation
import PayHub

public enum QRNavigation<ConfirmSberQR, MixedPicker, MultiplePicker, OperatorModel, Payments, QRFailure, ServicePicker> {
    
    case confirmSberQR(Node<ConfirmSberQR>)
    case failure(Failure)
    case mixedPicker(Node<MixedPicker>)
    case multiplePicker(Node<MultiplePicker>)
    case operatorModel(OperatorModel)
    case payments(Node<Payments>)
    case qrFailure(Node<QRFailure>)
    case servicePicker(Node<ServicePicker>)
    
    public enum Failure: Equatable {
        
        case sberQR(URL)
    }
}
