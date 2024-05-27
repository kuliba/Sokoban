//
//  RootViewFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

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
                makeAnywayPaymentFactory: makeAnywayPaymentFactory
            ),
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
        component: UIComponent
    ) -> IconView {
        
        return model.imageCache().makeIconView(for: component.md5Hash)
    }
    
    private typealias UIComponent = AnywayPaymentDomain.AnywayPayment.Element.UIComponent
}

private extension AnywayPaymentDomain.AnywayPayment.Element.UIComponent {
    
    var md5Hash: MD5Hash {
        #warning("FIXME")
        return .init("")
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
            return makeIconView(for: md5Hash)
        }
    }
    
    func makeIconView(
        for md5Hash: MD5Hash
    ) -> UIPrimitives.AsyncImage {
        
        let imageSubject = image(forKey: .init(md5Hash.rawValue))
        
        return .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
}
