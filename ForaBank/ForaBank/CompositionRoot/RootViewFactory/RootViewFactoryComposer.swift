//
//  RootViewFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ActivateSlider
import AnywayPaymentDomain
import Combine
import InfoComponent
import PaymentComponents
import SberQR
import SwiftUI
import UIPrimitives

final class RootViewFactoryComposer {
    
    private let model: Model
    
    init(model: Model) {
     
        self.model = model
    }
}

extension RootViewFactoryComposer {
    
    func compose() -> Factory {
        
        let imageCache = model.imageCache()

        return .init(
            makePaymentsTransfersView: makePaymentsTransfersView,
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeIconView: imageCache.makeIconView(for:), 
            makeActivateSliderView: ActivateSliderStateWrapperView.init, 
            makeUpdateInfoView: UpdateInfoView.init,
            makeAnywayPaymentFactory: makeAnywayPaymentFactory
        )
    }
}

extension RootViewFactoryComposer {
    
    typealias Factory = RootViewFactory
}

private extension RootViewFactoryComposer {
    
    func makePaymentsTransfersView(
        viewModel: PaymentsTransfersViewModel
    ) -> PaymentsTransfersView {
        
        let imageCache = model.imageCache()
        let getUImage = { self.model.images.value[$0]?.uiImage }

        return .init(
            viewModel: viewModel,
            viewFactory: .init(
                makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                makeUserAccountView: makeUserAccountView,
                makeIconView: imageCache.makeIconView(for:), 
                makeUpdateInfoView: UpdateInfoView.init(text:),
                makeAnywayPaymentFactory: makeAnywayPaymentFactory
            ), 
            productProfileViewFactory: .init(makeActivateSliderView: ActivateSliderStateWrapperView.init),
            getUImage: getUImage
        )
    }
    
    func makeSberQRConfirmPaymentView(
        viewModel: SberQRConfirmPaymentViewModel
    ) -> SberQRConfirmPaymentWrapperView {
        
        let imageCache = model.imageCache()
        
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
    
    func makeUserAccountView(
        viewModel: UserAccountViewModel
    ) -> UserAccountView {
        
        UserAccountView.init(viewModel: viewModel)
    }
    
    func makeAnywayPaymentFactory(
        event: @escaping (AnywayPaymentEvent) -> ()
    ) -> AnywayPaymentFactory<IconView> {
        
        let composer = AnywayPaymentFactoryComposer(
            config: .iFora,
            currencyOfProduct: currencyOfProduct,
            getProducts: model.productSelectProducts,
            makeIconView: makeIconView
        )
        
        return composer.compose(event: event)
    }
    
    private func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
    
    typealias IconView = UIPrimitives.AsyncImage
    
    private func makeIconView(
        _ icon: String
    ) -> IconView {
        
        return model.imageCache().makeIconView(for: .md5Hash(.init(icon)))
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
        for icon: IconDomain.Icon?
    ) -> UIPrimitives.AsyncImage {
        
        switch icon {
        case .none:
            return makeIconView(for: "placeholder")
            
        case let .md5Hash(md5Hash):
            return makeIconView(for: md5Hash.rawValue)
        }
    }
    
    func makeIconView(
        for rawValue: String
    ) -> UIPrimitives.AsyncImage {
        
        let imageSubject = image(forKey: .init(rawValue))
        
        return .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
}
