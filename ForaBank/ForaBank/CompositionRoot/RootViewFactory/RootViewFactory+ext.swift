//
//  RootViewFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ActivateSlider
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
        let makeSberQRConfirmPaymentView = Self.makeSberQRConfirmPaymentView(imageCache: imageCache)
        
        let makeUserAccountView = UserAccountView.init(viewModel:)
        
        let makeActivateSliderView = ActivateSliderStateWrapperView.init(payload:viewModel:config:)

        self.init(
            makePaymentsTransfersView: { viewModel in
                
                return .init(
                    viewModel: viewModel,
                    viewFactory: .init(
                        makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                        makeUserAccountView: makeUserAccountView,
                        makeIconView: imageCache.makeIconView(for:)
                    ),
                    productProfileViewFactory: .init(makeActivateSliderView: makeActivateSliderView),
                    getUImage: getUImage
                )
            },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeIconView: imageCache.makeIconView(for:),
            makeActivateSliderView: makeActivateSliderView
        )
    }
    
    static func makeSberQRConfirmPaymentView(
        imageCache: ImageCache
    ) -> (SberQRConfirmPaymentViewModel) -> SberQRConfirmPaymentWrapperView {
        
        return { viewModel in
            
            return .init(
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
    }
}

private extension GetSberQRDataResponse.Parameter.Info {
    
    var infoID: InfoComponent.PublishingInfo.ID {
        
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
