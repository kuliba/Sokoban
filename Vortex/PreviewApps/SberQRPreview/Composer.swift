//
//  Composer.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

final class Composer {
    
    let navigationModel: NavigationModel
    
    init(navigation: Navigation? = nil) {
        
        self.navigationModel = .init(navigation: navigation)
    }
}

// MARK: - Navigation

extension Composer {
    
    // MARK: - Alert
    
    func makeAlertView(
        _ alert: Navigation.Alert
    ) -> SwiftUI.Alert {
        
        .init(title: Text(alert.message))
    }

    // MARK: - Navigation
    
    @ViewBuilder
    func makeDestinationView(
        _ destination: Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .sberQRPayment(url):
            
            makeSberQRPaymentView(
                url: url,
                dismiss: navigationModel.resetNavigation
            )
        }
    }
    
    // MARK: - FullScreenCover
    
    @ViewBuilder
    func makeFullScreenCoverView(
        _ fullScreenCover: Navigation.FullScreenCover
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
        _ sheet: Navigation.Sheet
    ) -> some View {
        
        switch sheet {
        case let .sberQRPayment(url):
            
            makeSberQRPaymentView(
                url: url,
                dismiss: navigationModel.resetNavigation
            )
        }
    }
}

private extension Composer {
    
    func handleQRParsingResult(_ qrResult: QRParsingResult) {
        
        switch qrResult {
        case let .sberQR(url):
            changeNavigation(to: .sheet(.sberQRPayment(url)))
            
        case let .error(text):
            changeNavigation(to: .alert(.init(message: text)))
        }
    }
}

private extension Composer {
    
    func changeNavigation(to navigation: Navigation) {
        
        navigationModel.resetNavigation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            self?.navigationModel.setNavigation(to: navigation)
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
            
            self?.navigationModel.setFullScreenCover(to: .qrReader)
        }
    }
    
    func makeQRReader(
        commit: @escaping (QRParsingResult) -> Void
    ) -> some View {
        
        QRReaderStub(commit: commit)
    }
    
    func makeSberQRPaymentView(
        url: URL,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        SberQRPaymentView(
            url: url,
            dismiss: dismiss
        )
    }
}
