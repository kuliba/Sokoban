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
            
            rootViewInNavigationView(state: state, event: event)
                .loader(isLoading: state.isLoading)
        }
    }
}

private extension RootBinderView {
    
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
        .navigationViewStyle(.stack)
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
            
        case let .openProduct(openProduct):
            rootViewFactory.components.makeOpenProductView(
                for: openProduct,
                dismiss: { binder.flow.event(.dismiss) }
            )
            
        case let .productProfile(profile):
            productProfileView(profile)
            
        case let .standardPayment(picker):
            standardPaymentView(picker)
            
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
        case let .orderCardResponse(response):
            rootViewFactory.components.makeOrderCardCompleteView(response) {
                
                binder.flow.event(.dismiss)
            }
            
        case let .scanQR(qrScanner):
            qrScannerView(qrScanner)
            
        case let .templates(node):
            NavigationView {
                
                templatesView(node)
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private func qrScannerView(
        _ binder: QRScannerDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, _ in
            
            NavigationView {
                
                rootViewFactory.makeQRScannerView(binder)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
            .loader(isLoading: state.isLoading)
        }
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
            
        case let .openProduct(openProduct):
            return .openProduct(openProduct)
            
        case .orderCardResponse:
            return nil
            
        case let .outside(outside):
            switch outside {
            case let .productProfile(productId):
                return .productProfile(productId)
                
            case .tab:
                return nil
            }
            
        case .scanQR, .templates:
            return nil
            
        case let .standardPayment(node):
            return .standardPayment(node.model)
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(searchByUIN)
            
        case let .userAccount(userAccount):
            return .userAccount(userAccount)
        }
    }
    
    enum Destination {
        
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case openProduct(OpenProduct)
        case productProfile(ProductProfileViewModel)
        case searchByUIN(SearchByUIN)
        case standardPayment(PaymentProviderPickerDomain.Binder)
        case userAccount(UserAccountViewModel)
        
        typealias SearchByUIN = SearchByUINDomain.Binder
        typealias TemplatesNode = RootViewNavigation.TemplatesNode
    }
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case .failure:
            return nil
            
        case .openProduct, .outside:
            return nil
            
        case let .orderCardResponse(orderCardResponse):
            return .orderCardResponse(orderCardResponse)
            
        case let .scanQR(node):
            return .scanQR(node.model)
            
            // cases listed for explicit exhaustivity
        case .standardPayment, .searchByUIN, .userAccount:
            return nil
            
        case let .templates(node):
            return .templates(node)
        }
    }
    
    enum FullScreenCover {
        
        case orderCardResponse(OpenCardDomain.OrderCardResponse)
        case scanQR(QRScannerDomain.Binder)
        case templates(TemplatesNode)
    }
}

extension RootViewNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .makeStandardPaymentFailure:
            return .makeStandardPaymentFailure
            
        case let .openProduct(openProduct):
            switch openProduct {
            case let .card(openCard):
                return .openProduct(.card(.init(openCard.model)))
                
            case let .savingsAccount(openSavingsAccount):
                return .openProduct(.savingsAccount)

            case .unknown:
                return .openProduct(.unknown)
            }
            
        case let .productProfile(profile):
            return .productProfile(.init(profile))
            
        case let .standardPayment(picker):
            return .standardPayment(.init(picker))
            
        case let .searchByUIN(searchByUIN):
            return .searchByUIN(.init(searchByUIN))
            
        case let .userAccount(userAccount):
            return .userAccount(.init(userAccount))
        }
    }
    
    enum ID: Hashable {
        
        case makeStandardPaymentFailure
        case openProduct(OpenProductID)
        case productProfile(ObjectIdentifier)
        case searchByUIN(ObjectIdentifier)
        case standardPayment(ObjectIdentifier)
        case userAccount(ObjectIdentifier)
        
        enum OpenProductID: Hashable {
            
            case card(ObjectIdentifier)
            case savingsAccount
            case unknown
        }
    }
}

extension RootViewNavigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
        case .orderCardResponse:
            return .orderCardResponse
            
        case let .scanQR(qrRScanner):
            return .scanQR(.init(qrRScanner))
            
        case let .templates(node):
            return .templates(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case orderCardResponse
        case scanQR(ObjectIdentifier)
        case templates(ObjectIdentifier)
    }
}
