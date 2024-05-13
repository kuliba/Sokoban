//
//  RootViewFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import InfoComponent
import SberQR
import SwiftUI
import UIPrimitives

extension RootViewFactory {
    
    init(
        with imageCache: ImageCache,
        getUImage: @escaping (Md5hash) -> UIImage?
    ) {
        let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView = { viewModel in
            
                .init(
                    viewModel: viewModel,
                    map: { info in
                        
                        return  .init(
                            id: info.infoID,
                            value: info.value,
                            title: info.title,
                            image: imageCache.imagePublisher(for: info.icon),
                            style: .expanded
                        )
                    },
                    config: .iFora
                )
        }
        
        let makeUserAccountView = UserAccountView.init(viewModel:)
        
        self.init(
            makePaymentsTransfersView: { viewModel in
                
                return .init(
                    viewModel: viewModel,
                    viewFactory: .init(
                        makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                        makeUserAccountView: makeUserAccountView,
                        makeIconView: imageCache.makeIconView(for:)
                    ),
                    getUImage: getUImage
                )
            },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeIconView: imageCache.makeIconView(for:)
        )
    }
}

private extension GetSberQRDataResponse.Parameter.Info {
    
    var infoID: InfoComponent.Info.ID {
        
        switch id {
        case .amount:        return .amount
        case .brandName:     return .brandName
        case .recipientBank: return .recipientBank
        }
    }
}

extension ImageCache {
    
    func imagePublisher(
        for icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> ImageSubject {
        
        switch icon.type {
        case .local:
            return .init(.init(icon.value))
            
        case .remote:
            return image(forKey: .init(icon.value))
        }
    }
    
    func makeIconView(
        for icon: IconDomain.Icon
    ) -> UIPrimitives.AsyncImage {
        
        switch icon {
        case let .md5Hash(md5Hash):
            let imageSubject = image(forKey: .init(md5Hash.rawValue))
            
            return .init(
                image: imageSubject.value,
                publisher: imageSubject.eraseToAnyPublisher()
            )
        }
    }
}
