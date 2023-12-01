//
//  Composer.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

final class Composer {
    
    let routeModel: RouteModel
    
    init(route: Route = .empty) {
        
        self.routeModel = .init(route: route)
    }
}

// MARK: - Navigation

extension Composer {
    
    // MARK: - Navigation Destination
    
    @ViewBuilder
    func makeDestinationView(
        _ destination: Route.Destination
    ) -> some View {
        
        switch destination {
        case let .sberQRPayment(url):
            
            makeSberQRFeatureView(
                url: url,
                dismiss: routeModel.resetDestination
            )
        }
    }
    
    // MARK: - Modal: Alert
    
    func makeAlertView(
        _ alert: Route.Modal.Alert
    ) -> SwiftUI.Alert {
        
        .init(title: Text(alert.message))
    }
    
    // MARK: - Modal: FullScreenCover
    
    @ViewBuilder
    func makeFullScreenCoverView(
        _ fullScreenCover: Route.Modal.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case .qrReader:
            
            makeQRReader { [weak self] qrResult in
                
                self?.handleQRParsingResult(qrResult)
            }
        }
    }
    
    // MARK: - Modal: FullScreenCover
    
    @ViewBuilder
    func makeSheet(
        _ sheet: Route.Modal.Sheet
    ) -> some View {
        
        switch sheet {
        case let .sberQRPayment(url):
            
            makeSberQRFeatureView(
                url: url,
                dismiss: routeModel.resetSheet
            )
            .sheet(
                item: .init(
                    get: {
#warning("extract as property or helper")
                        guard case let .sheet(.picker(wrapped)) = self.routeModel.route.modal
                        else { return nil }
                        
                        return wrapped
                    },
                    set: { _ in
                        
#warning("fix this empty setter")
                    }
                ),
                content: { (wrapped: Route.Modal.Sheet.Wrapped) in
                    
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
                routeModel.setModal(to: .sheet(.sberQRPayment(url)))
            
        case let .error(text):
            routeModel.setModal(to: .alert(.init(message: text)))
        }
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
        route: SberQRFeatureRoute? = nil,
        url: URL,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        SberQRFeatureView(
            viewModel: .init(route: route),
            url: url,
            dismiss: dismiss
        )
    }
}
