//
//  RootViewModelFactory+getSplashScreenSettings.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.03.2025.
//

import Foundation
import RemoteServices
import SerialComponents
import SplashScreenBackend
import SplashScreenCore
import VortexTools

typealias SplashScreenImageStorage = CategorizedStorage<String, ImageSplashScreenSettings>
typealias SplashScreenLinkStorage = CategorizedStorage<String, LinkSplashScreenSettings>

extension RootViewModelFactory {
    
    struct WithReset<Value> {
        
        let value: Value
        let shouldResetCache: Bool
    }
    
    @inlinable
    func getSplashImages() {
        
        schedulers.background.schedule { [weak self] in
            
            self?.getAndCacheSplashImages()
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getAndCacheSplashImages() {
        
        getSplashImages { [weak self] in
            
            self?.loadSplashImagesCache()
            
            // TODO: extract caching
            guard let storage = $0.value else {
                
                self?.infoNetworkLog(message: "Fail to load Splash Images.")
                return
            }
            
            self?.cache(
                splashImages: storage,
                shouldResetCache: $0.shouldResetCache
            ) { [weak self] in
                
                self?.infoNetworkLog(message: "Got Splash Images for \(String(describing: storage.categories))")
            }
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashImagesCache() {

        guard let settings = model.localAgent.load(type: CategorizedStorage<String, CodableImageSplashScreenSettings>.self)
        else {
            return errorLog(category: .cache, message: "No SplashScreenSettings.")
        }
        
        let info = settings.categories.map {
        
            ($0, settings.items(for: $0)?.count ?? 0)
        }
        
        debugLog(category: .cache, message: "Loaded SplashScreenSettings for \(info)")
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func cache(
        splashImages storage: SplashScreenImageStorage,
        shouldResetCache: Bool,
        completion: @escaping () -> Void
    ) {
        let storage = storage.map(CodableImageSplashScreenSettings.init)
        
        do {
            if shouldResetCache {
                try model.localAgent.store(storage, serial: nil)
            } else {
                try model.localAgent.update(with: storage, serial: nil, using: CategorizedStorage.merge)
            }
        } catch {
            errorLog(category: .cache, message: "Failed to cache SplashImages.")
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getSplashImages(
        completion: @escaping (WithReset<SplashScreenImageStorage?>) -> Void
    ) {
        loadSplashScreenTimePeriods { [weak self] in
            
            let (periods, shouldResetCache) = ($0.value.map(\.timePeriod), $0.shouldResetCache)
            
            self?.loadSplashScreenSettings(periods: periods) { [weak self] in
                
                guard let self else { return }
                
                getSplashScreenImages(for: $0, with: getSplashScreenImage) {
                    
                    completion(.init(value: $0, shouldResetCache: shouldResetCache))
                }
            }
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashScreenTimePeriods(
        completion: @escaping (WithReset<[SplashScreenTimePeriods]>) -> Void
    ) {
        let (loadTimePeriods, reloadTimePeriods) = makeNoFallbackSplashScreenTimePeriodsLoaders()
        
        loadTimePeriods { localTimePeriods in
            
            reloadTimePeriods { remoteTimePeriods in
                
                completion(.init(
                    value: remoteTimePeriods ?? .default,
                    shouldResetCache: localTimePeriods != remoteTimePeriods
                ))
                
                _ = loadTimePeriods
                _ = reloadTimePeriods
            }
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashScreenSettings(
        periods: [String],
        completion: @escaping (LinkSplashScreenSettingsOutcome) -> Void
    ) {
        let loader = CategorizedLoader(
            initialStorage: nil,
            loadCategories: { $0(periods) },
            loadItems: splashScreenSettingsRemoteLoad
        )
        
        loader.load { completion($0); _ = loader }
    }
    
    typealias LinkSplashScreenSettingsOutcome = CategorizedOutcome<String, LinkSplashScreenSettings>
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getSplashScreenImages(
        for outcome: LinkSplashScreenSettingsOutcome,
        with getSplashScreenImage: @escaping GetSplashScreenImage,
        completion: @escaping (SplashScreenImageStorage?) -> Void
    ) {
        let imageLoader = BatchLoader(load: getSplashScreenImage)
        
        imageLoader.load(payloads: outcome.links) {
            
            completion(outcome.transform(with: $0))
            _ = imageLoader
        }
    }
    
    typealias GetSplashScreenImage = (String, @escaping (Result<Data, Error>) -> Void) -> Void
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getSplashScreenImage(
        splash: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let load = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetSplashScreenImageRequest(splash:),
            mapResponse: RemoteServices.ResponseMapper.mapGetSplashScreenImageResponse
        )
        
        load(splash) { completion($0); _ = load }
    }
}

// MARK: - TimePeriod

private extension Calendar {
    
    func timePeriod(
        for periods: [SplashScreenTimePeriod]?,
        with currentDate: @escaping () -> Date = Date.init
    ) -> String {
        
        let timeString = currentTimeString(currentDate: currentDate)
        let period = (periods ?? .default).period(for: timeString ?? "")
        
        return period?.timePeriod ?? "DAY"
    }
}

private extension Array where Element == SplashScreenTimePeriod {
    
    static let `default`: Self = [
        .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
        .init(timePeriod: "DAY",     startTime: "12:00", endTime: "17:59"),
        .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
        .init(timePeriod: "NIGHT",   startTime: "00:00", endTime: "03:59"),
    ]
}

// MARK: - Images

import Foundation
import RemoteServices
import SplashScreenBackend
import SwiftUI

// MARK: - Adapters, Helpers

private extension CategorizedOutcome
where Item == LinkSplashScreenSettings {
    
    var links: [String] {
        
        guard let storage else { return [] }
        
        return storage.categories
            .compactMap { storage.items(for: $0) }
            .flatMap { $0 }
            .map(\.link)
    }
}

private extension CategorizedOutcome
where Category == String,
      Item == LinkSplashScreenSettings {
    
    func transform(
        with outcome: Outcome<String, Data>
    ) -> SplashScreenImageStorage? {
        
        let images = outcome.storage.compactMapValues(Image.init)
        
        let imageSettings = storage?.compactMap { setting in
            
            images[setting.link].map {
                
                ImageSplashScreenSettings(image: $0, period: setting.period)
            }
        }
        
        return imageSettings
    }
}

// MARK: - Persistence (Cadable)

struct CodableImageSplashScreenSettings: Codable {
    
    let period: String
}

extension CodableImageSplashScreenSettings {
    
    init(_ settings: ImageSplashScreenSettings) {
        
        self.init(
            period: settings.period
        )
    }
}

extension CodableImageSplashScreenSettings: Categorized {
    
    var category: String { period }
}
