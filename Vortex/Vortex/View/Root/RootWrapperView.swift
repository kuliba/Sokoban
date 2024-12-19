//
//  RootWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import RxViewModel
import SwiftUI

struct RootWrapperView: View {
    
    @ObservedObject var flow: RootViewDomain.Flow
    
    let rootView: () -> RootView
    let viewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack {
            
            SpinnerView(viewModel: .init())
                .opacity(flow.state.isLoading ? 1 : 0)
                .zIndex(1.0)
            
            RxWrapperView(model: flow) { state, event in
                
                rootView()
                    .fullScreenCoverInspectable(
                        item: { state.navigation?.fullScreenCover },
                        dismiss: { event(.dismiss) },
                        content: fullScreenCoverContent
                    )
                    .navigationDestination(
                        destination: state.navigation?.destination,
                        // dismiss managed by flow, not SwiftUI
                        content: destinationContent
                    )
            }
        }
    }
}

private extension RootWrapperView {
    
    // MARK: - Destination
    
    @ViewBuilder
    func destinationContent(
        destination: RootViewNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .makeStandardPaymentFailure(binder):
            viewFactory.components.serviceCategoryFailureView(binder: binder)
            
        case let .productProfile(profile):
            productProfileView(profile)
            
        case let .standardPayment(picker):
            standardPaymentView(picker)
            
        case let .templates(node):
            templatesView(node)
            
        case let .userAccount(userAccount):
            userAccountView(userAccount)
        }
    }
    
    private func productProfileView(
        _ viewModel: ProductProfileViewModel
    ) -> some View {
        
        viewFactory.components.makeProductProfileView(viewModel)
    }
    
    private func standardPaymentView(
        _ picker: PaymentProviderPickerDomain.Binder
    ) -> some View {
        
        viewFactory.makePaymentProviderPickerView(picker)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.standardPayment)).rawValue)
    }
    
    private func templatesView(
        _ templates: RootViewNavigation.TemplatesNode
    ) -> some View {
        
        viewFactory.components.makeTemplatesListFlowView(templates)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.templates)).rawValue)
    }
    
    private func userAccountView(
        _ userAccount: UserAccountViewModel
    ) -> some View {
        
        viewFactory.makeUserAccountView(userAccount)
    }
    
    // MARK: - FullScreenCover
    
    @ViewBuilder
    func fullScreenCoverContent(
        fullScreenCover: RootViewNavigation.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case let .scanQR(qrScanner):
            qrScannerView(qrScanner)
        }
    }
    
    private func qrScannerView(
        _ qrScanner: QRScannerDomain.Binder
    ) -> some View {
        
        NavigationView {
            
            viewFactory.makeQRScannerView(qrScanner)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
    }
}

extension RootViewFactory {
    
    func makeQRScannerView(
        _ binder: QRScannerDomain.Binder
    ) -> some View {
        
        return QRWrapperView(
            binder: binder,
            factory: .init(
                makeAnywayServicePickerFlowView: components.makeAnywayServicePickerFlowView,
                makeIconView: makeIconView,
                makeOperatorView: InternetTVDetailsView.init,
                makePaymentsView: components.makePaymentsView,
                makeQRFailedWrapperView: components.makeQRFailedWrapperView,
                makeQRSearchOperatorView: components.makeQRSearchOperatorView,
                makeQRView: components.makeQRView,
                makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                makeSegmentedPaymentProviderPickerView: components.makeSegmentedPaymentProviderPickerView
            )
        )
    }
}

extension RootViewNavigation {
    
    var destination: Destination? {
        
        switch self {
            // TODO: make alert
        case let .failure(failure):
            switch failure {
            case let .makeStandardPaymentFailure(binder):
                return .makeStandardPaymentFailure(binder)
                
            case .makeUserAccountFailure:
                #warning("ADD ALERT")
                return nil
                
            case .missingCategoryOfType://(<#T##ServiceCategory.CategoryType#>):
                #warning("ADD ALERT(?)")
                return nil
                
            case let .makeProductProfileFailure(productID):
                #warning("ADD ALERT(?)")
                return nil
            }
            
        case let .outside(outside):
            switch outside {
            case let .productProfile(productId):
                return .productProfile(productId)
                
            case .tab:
                return nil
            }
            
        case .scanQR:
            return nil
            
        case let .standardPayment(node):
            return .standardPayment(node.model)
            
        case let .templates(node):
            return .templates(node)
            
        case let .userAccount(userAccount):
            return .userAccount(userAccount)
        }
    }
    
    enum Destination {
        
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case productProfile(ProductProfileViewModel)
        case standardPayment(PaymentProviderPickerDomain.Binder)
        case templates(TemplatesNode)
        case userAccount(UserAccountViewModel)
        
        typealias TemplatesNode = RootViewNavigation.TemplatesNode
    }
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case .failure:
            return nil
            
        case .outside:
            return nil
            
        case let .scanQR(node):
            return .scanQR(node.model)
            
            // cases listed for explicit exhaustivity
        case .standardPayment, .templates, .userAccount:
            return nil
        }
    }
    
    enum FullScreenCover {
        
        case scanQR(QRScannerDomain.Binder)
    }
}

extension RootViewNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .makeStandardPaymentFailure:
            return .makeStandardPaymentFailure
            
        case let .productProfile(profile):
            return .productProfile(.init(profile))
            
        case let .standardPayment(picker):
            return .standardPayment(.init(picker))
            
        case let .templates(templates):
            return .templates(.init(templates.model))
            
        case let .userAccount(userAccount):
            return .userAccount(.init(userAccount))
        }
    }
    
    enum ID: Hashable {
        
        case makeStandardPaymentFailure
        case productProfile(ObjectIdentifier)
        case standardPayment(ObjectIdentifier)
        case templates(ObjectIdentifier)
        case userAccount(ObjectIdentifier)
    }
}

extension RootViewNavigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .scanQR(qrRScanner):
            return .scanQR(.init(qrRScanner))
        }
    }
    
    enum ID: Hashable {
        
        case scanQR(ObjectIdentifier)
    }
}
