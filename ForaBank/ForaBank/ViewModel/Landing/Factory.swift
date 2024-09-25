//
//  Factory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 14.09.2023.
//

import SwiftUI
import LandingUIComponent
import Combine
import LandingMapping

extension Model {
    
    fileprivate typealias Images = [String: Image]
    fileprivate typealias ImagePublisher = AnyPublisher<Images, Never>
    fileprivate typealias ImageLoader = ([ImageRequest]) -> Void
    fileprivate typealias CurrentValueSubjectTA = CurrentValueSubject<Result<UILanding?, Error>, Never>
    fileprivate typealias StatePublisher = () -> AnyPublisher<Result<UILanding?, LandingWrapperViewModel.Error>, Never>
    
    func landingCardViewModelFactory(
        abroadType: AbroadType,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent.Card) -> () -> Void
    ) -> LandingWrapperViewModel {
        
        let service = self.getLandingCachingService(abroadType: abroadType) {
            
            self.currentValueSubject(abroadType).value = .success($0)
        }
        service.process(("", abroadType)) { [service] _ in _ = service }
        
        return LandingWrapperViewModel(
            statePublisher: statePublisher(abroadType)(),
            imagePublisher: imagePublisher(),
            imageLoader: imageLoader,
            makeIconView: { self.imageCache().makeIconView(for: .md5Hash(.init($0))) },
            scheduler: .main,
            config: config,
            landingActions: { event in
                switch event {
                case let .card(card):
                    return landingActions(card)()
                    
                case .sticker: break
                case .bannerAction: break
                case .listVerticalRoundImageAction: break
                }
            }
        )
    }
    
    func landingStickerViewModelFactory(
        abroadType: AbroadType,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent.Sticker) -> () -> Void
    ) -> LandingWrapperViewModel {
        
      let service = self.getLandingCachingService(abroadType: abroadType) {
            
            self.currentValueSubject(abroadType).value = .success($0)
        }
        service.process(("", abroadType)) { [service] _ in _ = service }
        
        return LandingWrapperViewModel(
            statePublisher: statePublisher(abroadType)(),
            imagePublisher: imagePublisher(),
            imageLoader: imageLoader,
            makeIconView: { self.imageCache().makeIconView(for: .md5Hash(.init($0))) },
            scheduler: .main,
            config: config,
            landingActions: { event in
                switch event {
                case .card: break
                case .bannerAction: break
                case let .sticker(sticker):
                    landingActions(sticker)()
                case .listVerticalRoundImageAction: break
                }
            }
        )
    }
    
    func landingSVCardViewModelFactory(
        result: Landing,
        limitsViewModel: ListHorizontalRectangleLimitsViewModel?,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent) -> Void
    ) -> LandingWrapperViewModel {
        
        return LandingWrapperViewModel(
            initialState: .success(.init(result)),
            imagePublisher: imagePublisher(),
            imageLoader: imageLoader,
            makeIconView: { self.imageCache().makeIconView(for: .md5Hash(.init($0))) },
            limitsViewModel: limitsViewModel,
            scheduler: .main,
            config: config,
            landingActions: landingActions
        )
    }
}

private extension Model {
    
    // MARK: - Current Value Subject
    func currentValueSubject(_ abroadType: AbroadType) -> CurrentValueSubjectTA {
        let currentValueSubject: CurrentValueSubject<Result<UILanding?, Error>, Never> = {
            switch abroadType {
            case .orderCard:
                return self.orderCardLanding
            case .transfer:
                return self.transferLanding
            case .sticker:
                return self.stickerLanding
            default:
                return .init(.failure(NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "No CurrentValueSubject"])))
            }
        }()
        return currentValueSubject
    }
    
    // MARK: - State Publisher
    func statePublisher(_ abroadType: AbroadType) -> StatePublisher {
        return {
            return self.currentValueSubject(abroadType)
                .map {
                    $0.mapError {
                        LandingWrapperViewModel.Error(
                            message: $0.localizedDescription
                        )
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - image Publisher
    func imagePublisher() -> ImagePublisher {
        
        return self.images
            .map {
                return Dictionary(
                    uniqueKeysWithValues:
                        $0.compactMap { key, value in
                            if let image = value.image { return (key, image) }
                            else { return nil }
                        })
            }
            .eraseToAnyPublisher()
    }
    
    
}

// MARK: - ImageLoader

private extension Model {
    
    // LoadImages
    func imageLoader(
        _ requests: [ImageRequest]
    ) {
        let md5hashs: [String] = requests.compactMap {
            
            guard case let ImageRequest.md5Hash(value) = $0,
                  self.images.value[value] == nil
            else { return nil }
            
            return value
        }
        
        self.handleDictionaryDownloadImages(payload: .init(imagesIds: md5hashs))
        
        let urls: [String] = requests.compactMap {
            
            guard case let ImageRequest.url(value) = $0,
                  self.images.value[value] == nil
            else { return nil }
            
            return value
        }
        
        urls.forEach {
            self.handleGeneralDownloadImageRequest(.init(endpoint: $0))
        }
    }
}

// MARK: - Services

private extension Model {
    
    // TODO: Remote + cache
    func getLandingCachingService(
        abroadType: AbroadType,
        observe: @escaping (UILanding) -> Void
    ) -> Services.GetLandingService {
        
        let httpClient: HTTPClient = {
            switch abroadType {
            case .orderCard, .transfer:
                return HTTPFactory.loggingNoSharedCookieStoreURLSessionHTTPClient()
            default:
                return self.authenticatedHTTPClient()
            }
        }()
                
        let cache: Services.Cache = { codableLanding in
            
            let landingUI = UILanding(codableLanding)
            
            observe(landingUI)
            
            let serial = codableLanding.serial
            
            let data: Codable = {
                
                switch abroadType {
                case .transfer:
                    return LocalAgentDomain.AbroadTransfer(landing: codableLanding)
                case .orderCard:
                    return LocalAgentDomain.AbroadOrderCard(landing: codableLanding)
                case .sticker:
                    return LocalAgentDomain.AbroadSticker(landing: codableLanding)
                case .marketShowcase:
                    return LocalAgentDomain.MarketShowcase(landing: codableLanding)
                    
                case let .control(cardType):
                    switch cardType {
                        
                    case .additionalOther:
                        return LocalAgentDomain.AdditionalOtherCard(landing: codableLanding)
                    case .additionalSelf:
                        return LocalAgentDomain.AdditionalSelfCard(landing: codableLanding)
                    case .additionalSelfAccOwn:
                        return LocalAgentDomain.AdditionalSelfAccOwnCard(landing: codableLanding)
                    case .main:
                        return LocalAgentDomain.MainCard(landing: codableLanding)
                    case .regular:
                        return LocalAgentDomain.RegularCard(landing: codableLanding)
                    case .additionalCorporate:
                        return LocalAgentDomain.AdditionalCorporateCard(landing: codableLanding)
                    case .corporate:
                        return LocalAgentDomain.CorporateCard(landing: codableLanding)
                    case .individualBusinessman:
                        return LocalAgentDomain.IndividualBusinessmanCard(landing: codableLanding)
                    case .individualBusinessmanMain:
                        return LocalAgentDomain.IndividualBusinessmanMainCard(landing: codableLanding)
                    }
                    
                case let .limit(cardType):
                    switch cardType {
                    case .additionalOther:
                        return LocalAgentDomain.LimitAdditionalOtherCard(landing: codableLanding)
                    case .additionalSelf:
                        return LocalAgentDomain.LimitAdditionalSelfCard(landing: codableLanding)
                    case .additionalSelfAccOwn:
                        return LocalAgentDomain.LimitAdditionalSelfAccOwnCard(landing: codableLanding)
                    case .main:
                        return LocalAgentDomain.LimitMainCard(landing: codableLanding)
                    case .regular:
                        return LocalAgentDomain.LimitRegularCard(landing: codableLanding)
                    case .additionalCorporate:
                        return LocalAgentDomain.LimitAdditionalCorporateCard(landing: codableLanding)
                    case .corporate:
                        return LocalAgentDomain.LimitCorporateCard(landing: codableLanding)
                    case .individualBusinessman:
                        return LocalAgentDomain.LimitIndividualBusinessmanCard(landing: codableLanding)
                    case .individualBusinessmanMain:
                        return LocalAgentDomain.LimitIndividualBusinessmanMainCard(landing: codableLanding)
                    }
                }
            }()
            
            try? self.localAgent.store(data, serial: serial)
        }
        
        return Services.getLandingService(
            httpClient: httpClient,
            withCache: cache)
    }
}
