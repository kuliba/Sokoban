//
//  Composer.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

final class Composer {
    
    let routeModel: RouteModel
    
    init(route: Route? = nil) {
        
        self.routeModel = .init(route: route)
    }
}

// MARK: - Navigation

extension Composer {
    
    // MARK: - Alert
    
    func makeAlertView(
        _ alert: Route.Alert
    ) -> SwiftUI.Alert {
        
        .init(title: Text(alert.message))
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    func makeDestinationView(
        _ destination: Route.Destination
    ) -> some View {
        
        switch destination {
        case let .sberQRPayment(url):
            
            makeSberQRFeatureView(
                url: url,
                dismiss: routeModel.resetRoute
            )
        }
    }
    
    // MARK: - FullScreenCover
    
    @ViewBuilder
    func makeFullScreenCoverView(
        _ fullScreenCover: Route.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case .qrReader:
            
            makeQRReader { [weak self] qrResult in
                
                self?.handleQRParsingResult(qrResult)
            }
        }
    }
    
    // MARK: - FullScreenCover
    
    @ViewBuilder
    func makeSheet(
        _ sheet: Route.Sheet
    ) -> some View {
        
        switch sheet {
        case let .sberQRPayment(url):
            
            makeSberQRFeatureView(
                url: url,
                dismiss: routeModel.resetRoute
            )
            .sheet(
                item: .init(
                    get: {
#warning("extract as property or helper")
                        guard case let .sheet(.picker(wrapped)) = self.routeModel.route
                        else { return nil }
                        
                        return wrapped
                    },
                    set: { _ in
                        
#warning("fix this empty setter")
                    }
                ),
                content: { (wrapped: Route.Sheet.Wrapped) in
                    
                    TextPickerView(commit: wrapped.closure)
                }
            )
            
        case let .picker(wrapped):
            TextPickerView(commit: wrapped.closure)
        }
    }
}

private extension Composer {
    
    func handleQRParsingResult(_ qrResult: QRParsingResult) {
        
        switch qrResult {
        case let .sberQR(url):
            changeRoute(to: .sheet(.sberQRPayment(url)))
            
        case let .error(text):
            changeRoute(to: .alert(.init(message: text)))
        }
    }
}

private extension Composer {
    
    func changeRoute(to route: Route) {
        
        routeModel.changeRoute(to: route)
    }
}

// MARK: - Compose Views

extension Composer {
    
    func makeMainView() -> some View {
        
        makeQRReaderButton()
    }
    
    func makeQRReaderButton() -> some View {
        
        QRReaderButton { [weak self] in
            
            self?.routeModel.setFullScreenCover(to: .qrReader)
        }
    }
    
    func makeQRReader(
        commit: @escaping (QRParsingResult) -> Void
    ) -> some View {
        
        QRReaderStub(commit: commit)
    }
    
    func makeSberQRFeatureView(
        selection: SberQRSelection? = nil,
        url: URL,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        SberQRFeatureView(
            viewModel: .init(selection: selection),
            url: url,
            dismiss: dismiss
        )
    }
}
