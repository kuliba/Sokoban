//
//  Factory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 14.09.2023.
//

import Foundation
import LandingUIComponent
import Combine

extension Model {
    
    func landingViewModelFactory(
        abroadType: AbroadType,
        config: UILanding.Component.Config,
        goMain: @escaping () -> Void,
        orderCard: @escaping (Int, Int) -> Void
    ) -> LandingWrapperViewModel {
        
        let imagePublisher = {
            
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
        
        let imageLoader = self.imageLoader
        
        let currentValueSubject = {
            switch abroadType {
            case .orderCard:
                return self.orderCardLanding
                
            case .transfer:
                return self.transferLanding
            }
        }()
        
        let service = self.getLandingCachingService(abroadType: abroadType) {
            
            currentValueSubject.value = .success($0)
        }
        
        service.process(("", abroadType)) { [service] _ in _ = service }
        
        let statePublisher = {
            
            return currentValueSubject
                .map {
                    $0.mapError {
                        LandingWrapperViewModel.Error(
                            message: $0.localizedDescription
                        )
                    }
                }
                .eraseToAnyPublisher()
        }
        
        return LandingWrapperViewModel(
            statePublisher: statePublisher(),
            imagePublisher: imagePublisher(),
            imageLoader: imageLoader,
            scheduler: .main,
            config: config,
            goMain: goMain,
            orderCard: orderCard
        )
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
        
        let httpClient: HTTPClient =  HTTPFactory.loggingNoSharedCookieStoreURLSessionHTTPClient()
        
        // TODO:
        /* let serial = localAgent.serial(for type: T.Type) -> String? {*/
        
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
                }
            }()
            
            try? self.localAgent.store(data, serial: serial)
        }
        
        return Services.getLandingService(
            httpClient: httpClient,
            withCache: cache)
    }
}
