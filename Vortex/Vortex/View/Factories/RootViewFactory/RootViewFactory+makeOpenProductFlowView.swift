//
//  RootViewFactory+makeOpenProductFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives
import LandingUIComponent

extension ViewComponents {
    
    @inlinable
    func makeOpenProductFlowView(
        _ flow: OpenProductDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            Color.clear
                .alert(
                    item: state.navigation?.alert,
                    content: { alert($0, event) }
                )
                .bottomSheet(
                    sheet: state.navigation?.bottomSheet,
                    dismiss: { event(.dismiss) },
                    content: makeOpenProductBottomSheetView
                )
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: makeOpenProductDestinationView
                )
        }
    }
    
    @inlinable
    func alert(
        _ alert: AlertModelOf<OpenProductDomain.FlowDomain.Event>,
        _ event: @escaping (OpenProductDomain.FlowDomain.Event) -> Void
    ) -> SwiftUI.Alert {
        
        .init(with: alert) { event ($0) }
    }
    
    @inlinable
    @ViewBuilder
    func makeOpenProductBottomSheetView(
        bottomSheet: OpenProductDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .openAccount(openAccount):
            OpenAccountView(viewModel: openAccount)
            
        case let .openProduct(openProduct):
            MyProductsOpenProductView(viewModel: openProduct)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeOpenProductDestinationView(
        destination: OpenProductDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .openCard(authProductsViewModel):
            makeAuthProductsView(authProductsViewModel)
            
        case let .openDeposit(openDeposit):
            makeOpenDepositListView(openDeposit)
            
        case let .openSticker(sticker):
            LandingWrapperView(viewModel: sticker)
                .ignoresSafeArea(edges: .bottom)
        }
    }
    
    @inlinable
    func makeAuthProductsView(
        _ viewModel: AuthProductsViewModel
    ) -> AuthProductsView {
        
        return .init(viewModel: viewModel)
    }
    
    @inlinable
    func makeOpenDepositListView(
        _ viewModel: OpenDepositListViewModel
    ) -> OpenDepositListView {
        
        return .init(viewModel: viewModel, getUImage: getUImage)
    }
}

extension OpenProductDomain.Navigation {
    
    var alert: AlertModel<OpenProductDomain.FlowDomain.Event, OpenProductDomain.FlowDomain.Event>? {
        
        guard case let .alert(message) = self else { return nil }
        
        return .error(message: message)
    }
    
    enum Alert {
        
        case message(String)
    }
    
    var bottomSheet: BottomSheet? {
        
        switch self {
        case .alert:
            return nil
            
        case let .openAccount(openAccount):
            return .openAccount(openAccount)
            
        case let .openProduct(node):
            return .openProduct(node.model)
            
        case .openCard, .openDeposit, .openURL, .openSticker(_), .main, .openLoan:
            return nil
        }
    }
    
    enum BottomSheet {
        
        case openAccount(OpenAccountViewModel)
        case openProduct(MyProductsOpenProductView.ViewModel)
    }
    
    var destination: Destination? {
        
        switch self {
        case .alert, .openAccount:
            return nil
            
        case let .openCard(authProductsViewModel):
            return .openCard(authProductsViewModel)
            
        case let .openDeposit(openDeposit):
            return .openDeposit(openDeposit)
            
        case .openProduct, .openURL, .main, .openLoan:
            return nil
            
        case let .openSticker(sticker):
            return .openSticker(sticker)
        }
    }
    
    enum Destination {
        
        case openCard(AuthProductsViewModel)
        case openDeposit(OpenDepositListViewModel)
        case openSticker(LandingWrapperViewModel)
    }
}

extension OpenProductDomain.Navigation.BottomSheet: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .openAccount(openAccount):
            return .openAccount(.init(openAccount))
            
        case let .openProduct(openProduct):
            return .openProduct(.init(openProduct))
        }
    }
    
    enum ID: Hashable {
        
        case openAccount(ObjectIdentifier)
        case openProduct(ObjectIdentifier)
    }
}

extension OpenProductDomain.Navigation.BottomSheet: BottomSheetCustomizable {}

extension OpenProductDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .openCard(openCard):
            return .openCard(.init(openCard))
            
        case let .openDeposit(openDeposit):
            return .openDeposit(.init(openDeposit))
            
        case let .openSticker(openSticker):
            return .openSticker(.init(openSticker))
        }
    }
    
    enum ID: Hashable {
        
        case openCard(ObjectIdentifier)
        case openDeposit(ObjectIdentifier)
        case openLoan
        case openSticker(ObjectIdentifier)
    }
}

// MARK: - Alerts

private extension AlertModelOf<OpenProductDomain.FlowDomain.Event> {
    
    static func error(
        message: String
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismiss
            )
        )
    }
}
