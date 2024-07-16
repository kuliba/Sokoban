//
//  RootViewFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ActivateSlider
import AnywayPaymentDomain
import Combine
import GenericRemoteService
import InfoComponent
import PaymentComponents
import PDFKit
import SberQR
import SwiftUI
import UIPrimitives

final class RootViewFactoryComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let historyFeatureFlag: HistoryFilterFlag
    
    init(
        model: Model,
        httpClient: HTTPClient,
        historyFeatureFlag: HistoryFilterFlag
    ) {
        self.model = model
        self.httpClient = httpClient
        self.historyFeatureFlag = historyFeatureFlag
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
            makeAnywayPaymentFactory: makeAnywayPaymentFactory,
            makePaymentCompleteView: makePaymentCompleteView, 
            makeHistoryButtonView: { event in self.makeHistoryButtonView(self.historyFeatureFlag, event: event) }
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
                makeAnywayPaymentFactory: makeAnywayPaymentFactory,
                makePaymentCompleteView: makePaymentCompleteView
            ),
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init,
                makeHistoryButton: { event in self.makeHistoryButtonView(self.historyFeatureFlag, event: event) }
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
            currencyOfProduct: currencyOfProduct,
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
        _  icon: AnywayElement.UIComponent.Icon?
    ) -> IconView {
        
        switch icon {
        case .none:
            return makeIconView("placeholder")
            
        case let .md5Hash(md5Hash):
            return makeIconView(md5Hash)
            
        case let .svg(svg):
            return .init(
                image: .init(svg: svg) ?? .init("placeholder"),
                publisher: Empty().eraseToAnyPublisher()
            )
            
        case let .withFallback(md5Hash: md5Hash, svg: _):
            return makeIconView(md5Hash)
        }
    }

    private func makeIconView(
        _ icon: String
    ) -> IconView {
        
        return model.imageCache().makeIconView(for: .md5Hash(.init(icon)))
    }
    
    func makePaymentCompleteView(
        result: TransactionResult,
        goToMain: @escaping () -> Void
    ) -> PaymentCompleteView {
        
        return PaymentCompleteView(
            state: map(result),
            goToMain: goToMain,
            factory: .init(
                makeDetailButton: TransactionDetailButton.init,
                makeDocumentButton: makeDocumentButton,
                makeTemplateButton: makeTemplateButtonView(with: result)
            )
        )
    }
    
    func makeHistoryButtonView(
        _ historyFeatureFlag: HistoryFilterFlag,
        event: @escaping (HistoryEvent) -> Void
    ) -> HistoryButtonView? {
        
        if historyFeatureFlag.rawValue {
            return HistoryButtonView(event: event)
        } else {
           return nil
        }
    }
    
    typealias TransactionResult = UtilityServicePaymentFlowState<AnywayTransactionViewModel>.FullScreenCover.TransactionResult
    
    private func map(
        _ result: TransactionResult
    ) -> PaymentCompleteView.State {
        
        return result
            .map {
                
                return .init(
                    status: $0.status,
                    detailID: $0.detailID,
                    details: model.makeTransactionDetailButtonDetail(with: $0.info)
                )
            }
            .mapError {
                
                return .init(
                    formattedAmount: $0.formattedAmount,
                    hasExpired: $0.hasExpired
                )
            }
    }
    
    private func makeDocumentButton(
        documentID: DocumentID
    ) -> TransactionDocumentButton {
        
        return .init(getDocument: getDocument(forID: documentID))
    }
    
    private func getDocument(
        forID documentID: DocumentID
    ) -> TransactionDocumentButton.GetDocument {
        
        let getDetailService = RemoteService(
            createRequest: RequestFactory.createGetPrintFormRequest(printFormType: .service),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: ResponseMapper.mapGetPrintFormResponse
        )
        
        return { completion in
 
            getDetailService.fetch(documentID) { result in
                
                completion(try? result.map(PDFDocument.init(data:)).get())
                _ = getDetailService
            }
        }
    }
    
    private func makeTemplateButtonView(
        with result: TransactionResult
    ) -> () -> TemplateButtonStateWrapperView? {
    
        return {
            
            guard let report = try? result.get(),
                  let operationDetail = report.info.operationDetail
            else { return nil }
            
            let viewModel = TemplateButtonStateWrapperView.ViewModel(
                model: self.model,
                operation: nil,
                operationDetail: operationDetail
            )
            
            return .init(viewModel: viewModel)
        }
    }
}

private extension AnywayTransactionReport {
    
    var detailID: Int {
        
        switch self.info {
        case let .detailID(detailID): return detailID
        case let .details(details):   return details.id
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
        for icon: IconDomain.Icon?
    ) -> UIPrimitives.AsyncImage {
        
        guard case let .md5Hash(md5Hash) = icon,
              !md5Hash.rawValue.isEmpty
        else { return makeIconView(for: "placeholder") }
                    
        return makeIconView(for: md5Hash.rawValue)
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
