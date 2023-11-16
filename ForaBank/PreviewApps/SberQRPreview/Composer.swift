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
    
    func makeMainView() -> some View {
        
        makeQRReaderButton()
    }
    
    @ViewBuilder
    func makeDestinationView(
        _ destination: Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .sberQRPayment(url):
            
            SberQRPaymentView(
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
            
            QRReaderStub { [weak self] qrResult in
                
                self?.handleQRParsingResult(qrResult)
            }
            
        case let .sberQRPayment(url):
            
            SberQRPaymentView(
                url: url,
                dismiss: navigationModel.resetNavigation
            )
        }
    }
    
    func handleQRParsingResult(_ qrResult: QRParsingResult) {
        
        switch qrResult {
        case let .sberQR(url):
            navigationModel.setFullScreenCover(to: .sberQRPayment(url))
            
        case let .error(text):
            // navigationModel.setAlert(text)
            navigationModel.resetNavigation()
        }
    }
    
    func makeQRReaderButton() -> some View {
        
        QRReaderButton { [weak self] in
            
            self?.navigationModel.setFullScreenCover(to: .qrReader)
        }
    }
}
