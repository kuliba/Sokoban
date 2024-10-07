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
                return .paymentFlow(.mobile(mobile))
                
            case .qr:
                return nil
                
            case let .standard(standard):
                return .paymentFlow(.standard(standard))
                
            case let .taxAndStateServices(taxAndStateServices):
                return .paymentFlow(.taxAndStateServices(taxAndStateServices))
                
            case let .transport(transport):
                return .paymentFlow(.transport(transport))
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
    
    enum Destination {
        
        case list(List)
        case paymentFlow(PaymentFlowDestination)
        case qrDestination(QRNavigation.Destination)
        
        typealias PaymentFlowDestination = PayHub.PaymentFlowDestination<ClosePaymentsViewModelWrapper, StandardSelectedCategoryDestination, ClosePaymentsViewModelWrapper, TransportPaymentsViewModel>
    }
}

extension SelectedCategoryNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .list:
            return .list
            
        case let .paymentFlow(paymentFlow):
            return .paymentFlow(paymentFlow.id)
            
        case let .qrDestination(qrDestination):
            return .qrDestination(qrDestination.id)
        }
    }
    
    enum ID: Hashable {
        
        case list
        case paymentFlow(PaymentFlowDestinationID)
        case qrDestination(QRNavigation.Destination.ID)
    }
}
