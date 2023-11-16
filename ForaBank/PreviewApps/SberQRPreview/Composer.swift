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
    
    func handleQRParsingResult(_ qrResult: QRParsingResult) {
        
        switch qrResult {
        case let .sberQR(url):
            navigationModel.setSheet(to: .sberQRPayment(url))
            
        case let .error(text):
            // navigationModel.setAlert(text)
            navigationModel.resetNavigation()
        }
    }
    
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
