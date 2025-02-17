//
//  QRNavigation+UI Mapping.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.10.2024.
//

import Foundation

// MARK: - UI mapping

extension QRNavigation {
    
    var failure: SelectedCategoryFailure? {
        
#warning("title is lost - a better way would be to wrap ErrorMessage in SelectedCategoryFailure")
        return errorMessage.map { .init(id: .init(), message: $0.message) }
    }
    
    private var errorMessage: ErrorMessage? {
        
        switch self {
        case
            let .paymentComplete(.failure(errorMessage)),
            let .sberQR(.failure(errorMessage)):
            return errorMessage
            
        default:
            return nil
        }
    }
    
    var destination: Destination? {
        
        switch self {
        case let .failure(qrFailedViewModel):
            return .qrFailedViewModel(qrFailedViewModel)
            
        case let .internetTV(internetTVDetailsViewModel):
            return .internetTV(internetTVDetailsViewModel)
            
        case let .operatorSearch(operatorSearch):
            return .operatorSearch(operatorSearch)
            
        case let .payments(node):
            return .payments(node.model)
            
        case .paymentComplete(.failure):
            return nil
            
        case let .providerPicker(node):
            return .providerPicker(node.model)
            
        case let .paymentComplete(.success(paymentComplete)):
            return .paymentComplete(paymentComplete)
            
        case .sberQR(.failure):
            return nil
            
        case let .sberQR(.success(sberQR)):
            return .sberQR(sberQR)
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(searchByUIN)
            
        case let .servicePicker(node):
            return .servicePicker(node.model)
        }
    }
}

extension QRNavigation {
    
    enum Destination {
        
        case qrFailedViewModel(QRFailedViewModel)
        case internetTV(InternetTVDetailsViewModel)
        case operatorSearch(OperatorSearch)
        case payments(ClosePaymentsViewModelWrapper)
        case paymentComplete(PaymentComplete)
        case providerPicker(ProviderPicker)
        case sberQR(SberQR)
        case searchByUIN(SearchByUIN)
        case servicePicker(AnywayServicePickerFlowModel)
        
        typealias SearchByUIN = SearchByUINDomain.Binder
    }
}

extension QRNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .qrFailedViewModel(qrFailedViewModel):
            return .qrFailedViewModel(.init(qrFailedViewModel))
            
        case .internetTV:
            return .internetTV
            
        case let .operatorSearch(operatorSearch):
            return .operatorSearch(.init(operatorSearch))
            
        case let .payments(payments):
            return .payments(.init(payments))
            
        case let .paymentComplete(paymentComplete):
            return .paymentComplete(.init(paymentComplete))
            
        case let .providerPicker(providerPicker):
            return .providerPicker(.init(providerPicker))
            
        case let .sberQR(sberQR):
            return .sberQR(.init(sberQR))
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(.init(searchByUIN))
            
        case let .servicePicker(servicePicker):
            return .servicePicker(.init(servicePicker))
        }
    }
    
    enum ID: Hashable {
        
        case internetTV
        case operatorSearch(ObjectIdentifier)
        case paymentComplete(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case providerPicker(ObjectIdentifier)
        case qrFailedViewModel(ObjectIdentifier)
        case sberQR(ObjectIdentifier)
        case searchByUIN(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
    }
}
