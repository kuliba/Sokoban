//
//  Composer.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

final class Composer {
    
    let navigationModel: NavigationModel
    
    init(navigationModel: NavigationModel = .init()) {
        
        self.navigationModel = navigationModel
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
            SberQRPaymentView(url: url)
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
        }
    }
    
    func handleQRParsingResult(_ qrResult: QRParsingResult) {
        
        switch qrResult {
        case let .sberQR(url):
            navigationModel.setDestination(to: .sberQRPayment(url))
            
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
