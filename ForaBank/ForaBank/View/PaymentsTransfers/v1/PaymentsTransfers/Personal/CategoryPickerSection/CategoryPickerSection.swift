//
//  CategoryPickerSection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import Foundation
import PayHub
import PayHubUI

typealias CategoryPickerSection = PayHubUI.CategoryPickerSection<ServiceCategory, CategoryPickerSectionNavigation>

enum CategoryPickerSectionNavigation {
    
    case destination(CategoryPickerSection.Destination)
    case failure(SelectedCategoryFailure)
    case fullScreenCover(CategoryPickerSection.FullScreenCover)
}

extension CategoryPickerSection {
    
    struct FullScreenCover: Identifiable {
        
        let id: UUID
        let qr: QRModel
    }
    
    enum Destination: Identifiable {
        
        case list(CategoryListModelStub)
        case mobile(ClosePaymentsViewModelWrapper)
        case standard(StandardSelectedCategoryDestination)
        case taxAndStateServices(ClosePaymentsViewModelWrapper)
        case transport(TransportPaymentsViewModel)
        
        var id: ID {
            
            switch self {
            case .list:                return .list
            case .mobile:              return .mobile
            case .standard:            return .standard
            case .taxAndStateServices: return .taxAndStateServices
            case .transport:           return .transport
            }
        }
        
        enum ID: Hashable {
            
            case list
            case mobile
            case standard
            case taxAndStateServices
            case transport
        }
    }
}

typealias SelectedCategoryDestination = PayHub.PaymentFlow<ClosePaymentsViewModelWrapper, QRModel, StandardSelectedCategoryDestination, ClosePaymentsViewModelWrapper, TransportPaymentsViewModel>

struct SelectedCategoryFailure: Error, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}
