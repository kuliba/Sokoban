//
//  QRScannerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.11.2024.
//

import SberQR

/// A namespace.
enum QRScannerDomain {}

extension QRScannerDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = QRScannerModel
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Outside: Equatable {
        
        case chat, main, payments
    }
    
    enum Select: Equatable {
        
        case outside(Outside)
        case qrResult(QRModelResult)
        case sberQRResponse(CreateSberQRPaymentResponse?)
    }
    
    enum Navigation {
        
        case failure(Node<QRMappingFailureDomain.Binder>)
        case operatorSearch(QRSearchOperatorViewModel)
        case operatorView(InternetTVDetailsViewModel)
        case outside(Outside)
        case payments(Node<PaymentsViewModel>)
        case providerPicker(Node<SegmentedPaymentProviderPickerFlowModel>)
        case providerServicePicker(AnywayServicePickerFlowModel)
        case sberQR(SberQRConfirmPaymentViewModel?)
        case sberQRComplete(PaymentsSuccessViewModel?)
        case searchByUIN(SearchByUIN)
        
        typealias SearchByUIN = SearchByUINDomain.Binder
    }
}
