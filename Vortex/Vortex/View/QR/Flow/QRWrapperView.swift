//
//  QRWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.11.2024.
//

import RxViewModel
import SberQR
import SwiftUI

struct QRWrapperView: View {
    
    let binder: QRScannerDomain.Binder
    let factory: QRWrapperViewFactory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            factory.makeQRView(binder.content.qrScanner)
                .navigationDestination(
                    destination: state.navigation?.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationContent
                )
                .accessibilityIdentifier(ElementIDs.qrScanner.rawValue)
        }
    }
}

struct QRWrapperViewFactory {
    
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
    let makeIconView: MakeIconView
    let makeOperatorView: MakeOperatorView
    let makePaymentsView: MakePaymentsView
    let makeQRFailedWrapperView: MakeQRFailedWrapperView
    let makeQRSearchOperatorView: MakeQRSearchOperatorView
    let makeQRView: MakeQRView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeSegmentedPaymentProviderPickerView: MakeSegmentedPaymentProviderPickerView
    let paymentsViewFactory: PaymentsViewFactory
    let rootViewFactory: RootViewFactory
    
    typealias MakeOperatorView = (InternetTVDetailsViewModel) -> InternetTVDetailsView
}

extension QRWrapperViewFactory {
    
    func makeQRMappingFailureView(
        binder: QRMappingFailureDomain.Binder
    ) -> some View {
        
        QRMappingFailureView(binder: binder) { destination in
            
            switch destination {
            case let .detailPayment(viewModel):
                // TODO: - replace with factory call
                PaymentsView(
                    viewModel: viewModel,
                    viewFactory: paymentsViewFactory
                )
                
            case let .categoryPicker(categoryPicker):
                rootViewFactory.components.makeCategoryPickerView(categoryPicker)
                    .onFirstAppear {
                        
                        categoryPicker.content.event(.load)
                    }
                    .navigationBarWithBack(
                        title: "Оплатить",
                        dismiss: { binder.flow.event(.dismiss) },
                        rightItem: .barcodeScanner(
                            action: { binder.flow.event(.select(.outside(.scanQR))) }
                        )
                    )
            }
        }
    }
}

private extension QRWrapperView {
    
#warning("add alert for sberQR failure case")
    
    typealias Destination = QRScannerDomain.Navigation.Destination
    
    @ViewBuilder
    func destinationContent(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case let .failure(binder):
            factory.makeQRMappingFailureView(binder: binder)
                .accessibilityIdentifier(ElementIDs.qrFailure.rawValue)
            
        case let .operatorSearch(search):
            factory.makeQRSearchOperatorView(search)
                .accessibilityIdentifier(ElementIDs.operatorSearch.rawValue)
            
        case let .operatorView(viewModel):
            factory.makeOperatorView(viewModel)
                .accessibilityIdentifier(ElementIDs.operatorView.rawValue)
            
        case let .payments(payments):
            factory.makePaymentsView(payments)
                .accessibilityIdentifier(ElementIDs.payments.rawValue)
            
        case let .providerPicker(picker):
            factory.makeSegmentedPaymentProviderPickerView(picker)
                .accessibilityIdentifier(ElementIDs.providerPicker.rawValue)
                .navigationBarWithBack(
                    title: "Оплатить",
                    dismiss: { binder.flow.event(.dismiss) },
                    rightItem: .barcodeScanner(
                        action: { binder.flow.event(.dismiss) }
                    )
                )

        case let .providerServicePicker(picker):
            factory.makeAnywayServicePickerFlowView(picker)
                .navigationBarWithAsyncIcon(
                    title: picker.title,
                    subtitle: picker.subtitle,
                    dismiss: { picker.event(.dismiss) },
                    icon: factory.makeIconView(picker.icon)
                )
                .accessibilityIdentifier(ElementIDs.providerServicePicker.rawValue)
            
        case let .sberQR(sberQRConfirm):
            factory.makeSberQRConfirmPaymentView(sberQRConfirm)
                .accessibilityIdentifier(ElementIDs.sberQRConfirm.rawValue)
                .navigationBarWithBack(
                    title: "Оплата по QR-коду",
                    dismiss: { binder.flow.event(.dismiss) }
                )
        }
    }
}

private extension AnywayServicePickerFlowModel {
    
    var title: String {
        
        state.content.state.payload.provider.origin.title
    }
    
    var subtitle: String? {
        
        state.content.state.payload.provider.origin.inn
    }
    
    var icon: IconDomain.Icon? {
        
        state.content.state.payload.provider.origin.icon.map { .md5Hash(.init($0)) }
    }
}

extension QRScannerDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .failure(node):
            return .failure(node.model)
            
        case let .operatorSearch(operatorSearch):
            return .operatorSearch(operatorSearch)
            
        case let .operatorView(operatorView):
            return .operatorView(operatorView)
            
        case .outside:
            return nil
            
        case let .payments(node):
            return .payments(node.model)
            
        case let .providerPicker(node):
            return .providerPicker(node.model)
            
        case let .providerServicePicker(picker):
            return .providerServicePicker(picker)
            
        case .sberQR(nil):
            return nil
            
        case let .sberQR(.some(sberQRConfirm)):
            return .sberQR(sberQRConfirm)
        }
    }
    
    enum Destination {
        
        case failure(QRMappingFailureDomain.Binder)
        case operatorSearch(QRSearchOperatorViewModel)
        case operatorView(InternetTVDetailsViewModel)
        case payments(PaymentsViewModel)
        case providerPicker(SegmentedPaymentProviderPickerFlowModel)
        case providerServicePicker(AnywayServicePickerFlowModel)
        case sberQR(SberQRConfirmPaymentViewModel)
    }
}

extension QRScannerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .failure(failure):
            return .failure(.init(failure))
            
        case let .operatorSearch(search):
            return .operatorSearch(.init(search))
            
        case .operatorView:
            return .operatorView
            
        case let .payments(payments):
            return .payments(.init(payments))
            
        case let .providerPicker(picker):
            return .providerPicker(.init(picker))
            
        case let .providerServicePicker(picker):
            return .providerServicePicker(.init(picker))
            
        case let .sberQR(sberQRConfirm):
            return .sberQR(.init(sberQRConfirm))
        }
    }
    
    enum ID: Hashable {
        
        case failure(ObjectIdentifier)
        case operatorSearch(ObjectIdentifier)
        case operatorView
        case payments(ObjectIdentifier)
        case providerPicker(ObjectIdentifier)
        case providerServicePicker(ObjectIdentifier)
        case sberQR(ObjectIdentifier)
    }
}
