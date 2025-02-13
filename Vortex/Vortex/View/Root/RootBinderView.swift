//
//  RootViewBinderView.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2024.
//

import RxViewModel
import SplashScreen
import SwiftUI

struct RootBinderView: View {
    
    let binder: RootViewDomain.Binder
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            ZStack {
                
                RxWrapperView(
                    model: binder.content.splash,
                    makeContentView: rootViewFactory.makeSplashScreenView
                )
                .zIndex(2.0)
                
                rootViewInNavigationView(state: state, event: event)
                spinnerView(isShowing: state.isLoading)
            }
        }
    }
}

private extension RootBinderView {
    
    func spinnerView(
        isShowing: Bool
    ) -> some View {
        
        SpinnerView(viewModel: .init())
            .opacity(isShowing ? 1 : 0)
            .animation(.easeInOut, value: isShowing)
    }
    
    func rootViewInNavigationView(
        state: RootViewDomain.FlowDomain.State,
        event: @escaping (RootViewDomain.FlowDomain.Event) -> Void
    ) -> some View {
        
        NavigationView {
            
            rootView()
                .navigationBarHidden(true)
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
    
    func rootView() -> RootView {
        
        return .init(
            viewModel: binder.content,
            rootViewFactory: rootViewFactory
        )
    }
    
    // MARK: - Destination
    
    @ViewBuilder
    func destinationContent(
        destination: RootViewNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .makeStandardPaymentFailure(binder):
            rootViewFactory.components.serviceCategoryFailureView(binder: binder)
            
        case let .productProfile(profile):
            productProfileView(profile)
            
        case let .standardPayment(picker):
            standardPaymentView(picker)
            
        case let .templates(node):
            templatesView(node)
            
        case let .searchByUIN(searchByUIN):
            searchByUINView(searchByUIN)
            
        case let .userAccount(userAccount):
            userAccountView(userAccount)
        }
    }
    
    private func productProfileView(
        _ viewModel: ProductProfileViewModel
    ) -> some View {
        
        rootViewFactory.components.makeProductProfileView(viewModel)
    }
    
    private func standardPaymentView(
        _ picker: PaymentProviderPickerDomain.Binder
    ) -> some View {
        
        rootViewFactory.components.makePaymentProviderPickerView(
            binder: picker,
            dismiss: { binder.flow.event(.dismiss) }
        )
        .accessibilityIdentifier(ElementIDs.rootView(.destination(.standardPayment)).rawValue)
    }
    
    private func templatesView(
        _ templates: RootViewNavigation.TemplatesNode
    ) -> some View {
        
        rootViewFactory.components.makeTemplatesListFlowView(templates)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.templates)).rawValue)
    }
    
    private func searchByUINView(
        _ searchByUIN: SearchByUINDomain.Binder
    ) -> some View {
        
        rootViewFactory.components.searchByUINView(searchByUIN)
            .navigationBarWithBack(
                title: "Поиск по УИН",
                subtitle: "Поиск начислений по УИН",
                dismiss: { binder.flow.event(.dismiss) },
                rightItem: .barcodeScanner {
                    
                    binder.flow.event(.select(.scanQR))
                }
            )
            .disablingLoading(flow: searchByUIN.flow)
    }
    
    private func userAccountView(
        _ userAccount: UserAccountViewModel
    ) -> some View {
        
        rootViewFactory.makeUserAccountView(userAccount)
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
            
            rootViewFactory.makeQRScannerView(qrScanner)
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
                makeSegmentedPaymentProviderPickerView: components.makeSegmentedPaymentProviderPickerView,
                paymentsViewFactory: paymentsViewFactory,
                rootViewFactory: self,
                components: components
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
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(searchByUIN)
            
        case let .userAccount(userAccount):
            return .userAccount(userAccount)
        }
    }
    
    enum Destination {
        
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case productProfile(ProductProfileViewModel)
        case searchByUIN(SearchByUIN)
        case standardPayment(PaymentProviderPickerDomain.Binder)
        case templates(TemplatesNode)
        case userAccount(UserAccountViewModel)
        
        typealias SearchByUIN = SearchByUINDomain.Binder
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
        case .standardPayment, .templates, .searchByUIN, .userAccount:
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
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(.init(searchByUIN))
            
        case let .userAccount(userAccount):
            return .userAccount(.init(userAccount))
        }
    }
    
    enum ID: Hashable {
        
        case makeStandardPaymentFailure
        case productProfile(ObjectIdentifier)
        case searchByUIN(ObjectIdentifier)
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
