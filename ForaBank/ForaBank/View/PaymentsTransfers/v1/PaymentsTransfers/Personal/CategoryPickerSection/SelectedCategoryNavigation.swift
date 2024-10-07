//
//  SelectedCategoryNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

typealias CategoryPickerSectionNavigation = SelectedCategoryNavigation<CategoryListModelStub>
typealias PlainCategoryPickerSectionNavigation = SelectedCategoryNavigation<Never>

enum SelectedCategoryNavigation<List> {
    
    case failure(SelectedCategoryFailure)
    case list(List)
    case paymentFlow(PaymentFlow)
    case qrNavigation(QRNavigation)
    
    typealias PaymentFlow = PayHub.PaymentFlow<ClosePaymentsViewModelWrapper, Node<QRModel>, StandardSelectedCategoryDestination, ClosePaymentsViewModelWrapper, TransportPaymentsViewModel>
    
    typealias QRNavigation = ForaBank.QRNavigation
}

struct SelectedCategoryFailure: Error, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}

// MARK: - UI mapping

extension SelectedCategoryNavigation {
    
    var destination: Destination? {
        
        switch self {
        case .failure:
            return nil
            
        case let .list(list):
            return .list(list)
            
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                return .mobile(mobile)
                
            case .qr:
                return nil
                
            case let .standard(standard):
                return .standard(standard)
                
            case let .taxAndStateServices(taxAndStateServices):
                return .taxAndStateServices(taxAndStateServices)
                
            case let .transport(transport):
                return .transport(transport)
            }
            
        case let .qrNavigation(qrNavigation):
            return qrNavigation.destination.map { .qrDestination($0) }
        }
    }
    
    var failure: SelectedCategoryFailure? {
        
        switch self {
        case let .failure(failure):
            return failure
            
        case let .qrNavigation(qrNavigation):
            return qrNavigation.failure
            
        default:
            return nil
        }
    }
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .paymentFlow(.qr(qr)) = self else { return nil }
        
        return .init(id: .init(), qr: qr.model)
    }
}

extension SelectedCategoryNavigation {
    
    struct FullScreenCover: Identifiable {
        
        let id: UUID
        let qr: QRModel
    }
    
    enum Destination: Identifiable {
        
        case list(List)
        case mobile(ClosePaymentsViewModelWrapper)
        case standard(StandardSelectedCategoryDestination)
        case taxAndStateServices(ClosePaymentsViewModelWrapper)
        case transport(TransportPaymentsViewModel)
        case qrDestination(QRNavigation.Destination)
        
        var id: ID {
            
            switch self {
            case .list:                return .list
            case .mobile:              return .mobile
            case .standard:            return .standard
            case .taxAndStateServices: return .taxAndStateServices
            case .transport:           return .transport

            case let .qrDestination(qrDestination):
                return .qrDestination(qrDestination.id)
            }
        }
        
        enum ID: Hashable {
            
            case list
            case mobile
            case standard
            case taxAndStateServices
            case transport
            case qrDestination(QRNavigation.Destination.ID)
        }
    }
}
