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
    case paymentComplete(PaymentCompleteResult)
    case payments(Node<ClosePaymentsViewModelWrapper>)
    case providerPicker(Node<ProviderPicker>)
    case sberQR(SberQRResult)
    case searchByUIN(SearchByUIN)
    case servicePicker(Node<AnywayServicePickerFlowModel>)
    
    typealias OperatorSearch = QRSearchOperatorViewModel
    typealias PaymentCompleteResult = Result<PaymentComplete, ErrorMessage>
    typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
    typealias SberQRResult = Result<SberQR, ErrorMessage>
    
    typealias PaymentComplete = PaymentsSuccessViewModel
    typealias SberQR = SberQRConfirmPaymentViewModel
    
    typealias SearchByUIN = SearchByUINDomain.Binder
    
    struct ErrorMessage: Error, Equatable {
        
        let title: String
        let message: String
    }
}
