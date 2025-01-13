//
//  QRMappingFailureView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct QRMappingFailureView<DestinationView: View>: View {
    
    let binder: Domain.Binder
    
    @ViewBuilder
    let destinationView: (Domain.Navigation.Destination) -> DestinationView
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            QRFailedContentView(
                event: { event(.select($0)) }
            )
            .navigationBarWithBack(
                title: "",
                dismiss: { event(.dismiss) }
            )
            .navigationDestination(
                destination: state.navigation?.destination,
                content: destinationView
            )
        }
    }
}

extension QRMappingFailureView {
    
    typealias Domain = QRMappingFailureDomain
}

private extension QRFailedContentView {
    
    init(
        event: @escaping (QRMappingFailureDomain.Select) -> Void
    ) {
        self.init(
            title: "Не удалось распознать QR-код",
            subtitle: "Воспользуйтесь другими способами оплаты",
            buttons: [
                .init(
                    title: "Найти поставщика вручную",
                    style: .gray,
                    action: { event(.manualSearch) }
                ),
                .init(
                    title: "Оплатить по реквизитам",
                    style: .gray,
                    action: { event(.detailPayment) }
                ),
            ]
        )
    }
}

extension QRMappingFailureDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case .back:
            return nil
            
        case let .detailPayment(node):
            return .detailPayment(node.model)
            
        case let .categoryPicker(binder):
            return .categoryPicker(binder)
            
        case .scanQR:
            return nil
        }
    }
    
    enum Destination {
        
        case categoryPicker(CategoryPicker)
        case detailPayment(PaymentsViewModel)
    }
}

extension QRMappingFailureDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .categoryPicker:
            return .categoryPicker
            
        case let .detailPayment(detailPayment):
            return .detailPayment(.init(detailPayment))
        }
    }
    
    enum ID: Hashable {
        
        case categoryPicker
        case detailPayment(ObjectIdentifier)
    }
}
