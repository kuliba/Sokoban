//
//  QRNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.10.2024.
//

import SberQR

enum QRNavigation {
    
    case failure(QRFailedViewModel)
    case internetTV(InternetTVDetailsViewModel)
    case operatorSearch(OperatorSearch)
    case payments(Node<ClosePaymentsViewModelWrapper>)
    case paymentComplete(PaymentCompleteResult)
    case providerPicker(Node<ProviderPicker>)
    case sberQR(SberQRResult)
    case servicePicker(Node<AnywayServicePickerFlowModel>)
    
    typealias OperatorSearch = QRSearchOperatorViewModel
    typealias PaymentCompleteResult = Result<PaymentComplete, ErrorMessage>
    typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
    typealias SberQRResult = Result<SberQR, ErrorMessage>
    
    typealias PaymentComplete = PaymentsSuccessViewModel
    typealias SberQR = SberQRConfirmPaymentViewModel
    
    struct ErrorMessage: Error, Equatable {
        
        let title: String
        let message: String
    }
}
