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
import MarketShowcase

final class RootViewFactoryComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let historyFeatureFlag: HistoryFilterFlag
    private let marketFeatureFlag: MarketplaceFlag

    init(
        model: Model,
        httpClient: HTTPClient,
        historyFeatureFlag: HistoryFilterFlag,
        marketFeatureFlag: MarketplaceFlag
    ) {
        self.model = model
        self.httpClient = httpClient
        self.historyFeatureFlag = historyFeatureFlag
        self.marketFeatureFlag = marketFeatureFlag
    }
}

extension RootViewFactoryComposer {
    
    func compose() -> Factory {
        
        let imageCache = model.imageCache()
        let generalImageCache = model.generalImageCache()

        return .init(
            makeActivateSliderView: ActivateSliderStateWrapperView.init,
            makeAnywayPaymentFactory: makeAnywayPaymentFactory,
            makeHistoryButtonView: { event, isFiltered, isDateFiltered, clearAction in
                self.makeHistoryButtonView(
                    self.historyFeatureFlag,
                    isFiltered: isFiltered,
                    isDateFiltered: isDateFiltered,
                    clearAction: clearAction,
                    event: event
                )
            },
            makeIconView: imageCache.makeIconView(for:),
            makeGeneralIconView: generalImageCache.makeIconView(for:),
            makePaymentCompleteView: makePaymentCompleteView,
            makePaymentsTransfersView: makePaymentsTransfersView,
            makeReturnButtonView: { action in self.makeReturnButtonView(self.historyFeatureFlag, action: action) },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeInfoViews: .default,
            makeUserAccountView: makeUserAccountView,
            makeMarketShowcaseView: makeMarketShowcaseView
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
        let generalImageCache = model.generalImageCache()

        let getUImage = { self.model.images.value[$0]?.uiImage }
        
        return .init(
            viewModel: viewModel,
            viewFactory: .init(
                makeAnywayPaymentFactory: makeAnywayPaymentFactory,
                makeIconView: imageCache.makeIconView(for:),
                makeGeneralIconView: generalImageCache.makeIconView(for:),
                makePaymentCompleteView: makePaymentCompleteView,
                makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                makeInfoViews: .default,
                makeUserAccountView: makeUserAccountView
            ),
            productProfileViewFactory: .init(
                makeActivateSliderView: ActivateSliderStateWrapperView.init,
                makeHistoryButton: {
                    self.makeHistoryButtonView(
                        self.historyFeatureFlag,
                        isFiltered: $1,
                        isDateFiltered: $2,
                        clearAction: $3,
                        event: $0
                    )
                },
                makeRepeatButtonView: { action in self.makeReturnButtonView(self.historyFeatureFlag, action: action) }
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
        result: Completed,
        goToMain: @escaping () -> Void
    ) -> PaymentCompleteView {
        
        return PaymentCompleteView(
            state: map(result),
            goToMain: goToMain,
            repeat: {},
            factory: .init(
                makeDetailButton: TransactionDetailButton.init,
                makeDocumentButton: makeDocumentButton,
                makeTemplateButton: makeTemplateButtonView(with: result)
            ), 
            makeIconView: {
                
                self.makeIconView($0.map { .md5Hash(.init($0)) })
            },
            config: .iFora
        )
    }
    
    func makeReturnButtonView(
        _ historyFeatureFlag: HistoryFilterFlag,
        action: @escaping () -> Void
    ) -> RepeatButtonView? {
        
        if historyFeatureFlag.rawValue {
            return RepeatButtonView(action: action)
            
        } else {
           return nil
        }
    }
    
    func makeHistoryButtonView(
        _ historyFeatureFlag: HistoryFilterFlag,
        isFiltered: @escaping () -> Bool,
        isDateFiltered: @escaping () -> Bool,
        clearAction: @escaping () -> Void,
        event: @escaping (ProductProfileFlowEvent.ButtonEvent) -> Void
    ) -> HistoryButtonView? {
        
        if historyFeatureFlag.rawValue {
            return HistoryButtonView(
                event: event,
                isFiltered: isFiltered,
                isDateFiltered: isDateFiltered,
                clearOptions: clearAction
            )
        } else {
           return nil
        }
    }
    
    typealias Completed = AnywayCompleted

    private func map(
        _ completed: Completed
    ) -> PaymentCompleteView.State {
        
        return .init(
            formattedAmount: completed.formattedAmount,
            merchantIcon: completed.merchantIcon,
            result: completed.result
                .map {
                    
                    return .init(
                        detailID: $0.detailID,
                        details: model.makeTransactionDetailButtonDetail(with: $0.info),
                        status: $0.status
                    )
                }
                .mapError {
                    
                    return .init(hasExpired: $0.hasExpired)
                }
        )
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
        with completed: Completed
    ) -> () -> TemplateButtonStateWrapperView? {
    
        return {
            
            guard let report = try? completed.result.get(),
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
    
    func makeMarketShowcaseView(
        viewModel: MarketShowcaseDomain.Binder
    ) -> MarketShowcaseWrapperView? {
        marketFeatureFlag.isActive ?
        
            .init(
                model: viewModel.flow,
                makeContentView: {
                    MarketShowcaseFlowView(
                        state: $0,
                        event: $1) {
                            MarketShowcaseContentWrapperView(
                                model: viewModel.content,
                                makeContentView: {
                                    MarketShowcaseContentView(
                                        state: $0,
                                        event: $1,
                                        config: .iFora,
                                        factory: .init(
                                            makeRefreshView: { SpinnerRefreshView(icon: .init("Logo Fora Bank")) })
                                    )
                                })
                        }
                })
        : nil
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
        
        switch icon {
        case let .svg(svg):
            return makeSVGIconView(for: svg)
        
        case let .md5Hash(md5Hash) where !md5Hash.rawValue.isEmpty:
            return makeIconView(for: md5Hash.rawValue)
            
        case let .image(imageLink) where !imageLink.isEmpty:
            return makeIconView(for: imageLink)
        
        default:
            return makeIconView(for: "placeholder")
        }
    }
    
    func makeSVGIconView(
        for svg: String
    ) -> UIPrimitives.AsyncImage {
        
        guard let image = Image(svg: svg)
        else { return makeIconView(for: "placeholder") }
        
        return .init(
            image: image,
            publisher: Just(image).eraseToAnyPublisher()
        )
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

extension RootViewFactory.MakeInfoViews {
    
    static let `default`: Self = .init(
        makeUpdateInfoView: UpdateInfoView.init(text:),
        makeDisableCorCardsInfoView: DisableCorCardsView.init(text:)
    )
}
