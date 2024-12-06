//
//  QRNavigationComposerMicroServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.10.2024.
//

import ForaTools
import Foundation
import SberQR

struct QRNavigationComposerMicroServices {
    
    let makeInternetTV: MakeInternetTV
    let makeOperatorSearch: MakeOperatorSearch
    let makePayments: MakePayments
    let makeProviderPicker: MakeProviderPicker
    let makeQRFailure: MakeQRFailure
    let makeQRFailureWithQR: MakeQRFailureWithQR
    let makeSberPaymentComplete: MakeSberPaymentComplete
    let makeSberQR: MakeSberQR
    let makeServicePicker: MakeServicePicker
}

extension QRNavigationComposerMicroServices {
    
    // MARK: - MakeInternetTV
    
    typealias MakeInternetTVPayload = (QRCode, QRMapping)
    typealias MakeInternetTV = (MakeInternetTVPayload, @escaping (InternetTVDetailsViewModel) -> Void) -> Void
    
    // MARK: - MakeOperatorSearch
    
    struct MakeOperatorSearchPayload {
        
        let multiple: MultiElementArray<SegmentedOperatorData>
        let qrCode: QRCode
        let qrMapping: QRMapping
        let chat: () -> Void
        let detailPayment: () -> Void
        let dismiss: () -> Void
    }
    
    typealias MakeOperatorSearch = (MakeOperatorSearchPayload, @escaping (QRNavigation.OperatorSearch) -> Void) -> Void
    
    // MARK: - MakePayments
    
    enum MakePaymentsPayload: Equatable {
        
        case operationSource(Payments.Operation.Source)
        case qrCode(QRCode)
        case source(Source)
    }
    
    typealias MakePayments = (MakePaymentsPayload, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
    
    // MARK: - MakeProviderPicker
    
    struct MakeProviderPickerPayload: Equatable {
        
        let mixed: MultiElementArray<SegmentedOperatorProvider>
        let qrCode: QRCode
        let qrMapping: QRMapping
    }
    
    typealias MakeProviderPicker = (MakeProviderPickerPayload, @escaping (QRNavigation.ProviderPicker) -> Void) -> Void
    
    // MARK: - MakeQRFailure
    
    struct MakeQRFailurePayload {
        
        let chat: () -> Void
        let detailPayment: () -> Void
    }
    
    typealias MakeQRFailure = (MakeQRFailurePayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    // MARK: - MakeQRFailureWithQR
    
    struct MakeQRFailureWithQRPayload {
        
        let qrCode: QRCode
        let chat: () -> Void
        let detailPayment: (QRCode) -> Void
    }
    
    typealias MakeQRFailureWithQR = (MakeQRFailureWithQRPayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    // MARK: - MakeSberPaymentComplete
    
    typealias MakeSberPaymentCompletePayload = (URL, SberQRConfirmPaymentState)
    typealias MakeSberPaymentComplete = (MakeSberPaymentCompletePayload, @escaping (QRNavigation.PaymentCompleteResult) -> Void) -> Void
    
    // MARK: - MakeSberQR
    
    typealias SberPay = (SberQRConfirmPaymentState) -> Void
    typealias MakeSberQRPayload = (url: URL, pay: SberPay)
    typealias MakeSberQRCompletion = (Result<QRNavigation.SberQR, QRNavigation.ErrorMessage>) -> Void
    typealias MakeSberQR = (MakeSberQRPayload, @escaping MakeSberQRCompletion) -> Void
    
    // MARK: - MakeServicePicker
    
    typealias ServicePicker = AnywayServicePickerFlowModel
    typealias MakeServicePicker = (PaymentProviderServicePickerPayload, @escaping (ServicePicker) -> Void) -> Void
}

extension QRNavigationComposerMicroServices.MakePaymentsPayload {
    
    struct Source: Equatable {
        
        let url: URL
        let type: SourceType
        
        enum SourceType: Equatable {
            
            case c2bSubscribe
            case c2b
        }
        
        static func c2bSubscribe(_ url: URL) -> Self {
            
            return .init(url: url, type: .c2bSubscribe)
        }
        
        static func c2b(_ url: URL) -> Self {
            
            return .init(url: url, type: .c2b)
        }
    }
}
