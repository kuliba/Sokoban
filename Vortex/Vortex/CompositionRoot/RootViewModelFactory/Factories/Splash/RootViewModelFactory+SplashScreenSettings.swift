//
//  RootViewModelFactory+SplashScreenSettings.swift
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

typealias SplashScreenStorage = CategorizedStorage<String, SplashScreenSettings>

// MARK: - Settings and Images

extension RootViewModelFactory {
    
    @inlinable
    func scheduleGetAndCacheSplashImages() {
        
        schedulers.background.schedule { [weak self] in
            
            self?.getAndCacheSplashImages()
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getAndCacheSplashImages() {
        
        getSplashImages { [weak self] storage in
            
            guard let storage else {
                
                self?.infoNetworkLog(message: "Fail to load Splash Images.")
                return
            }
            
            self?.cache(splashImages: storage)
            self?.infoNetworkLog(message: "Got Splash Images: \(String(describing: storage))")
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getSplashImages(
        completion: @escaping (SplashScreenStorage?) -> Void
    ) {
        loadSplashScreenTimePeriodsCache { [weak self] in
            
            let periods = $0.map(\.timePeriod)
            
            self?.loadSplashScreenSettings(forPeriods: periods) { [weak self] in
                
                guard let self else { return }
                
                getSplashScreenImages(
                    for: $0,
                    with: getSplashScreenImage,
                    completion: completion
                )
            }
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashScreenSettings(
        forPeriods periods: [String],
        completion: @escaping (SplashScreenSettingsOutcome) -> Void
    ) {
        let initialStorage = loadSplashImagesCache()
        
        let loader = CategorizedLoader(
            initialStorage: initialStorage,
            loadCategories: { $0(periods) },
            loadItems: splashScreenSettingsRemoteLoad
        )
        
        loader.load { completion($0); _ = loader }
    }
    
    @inlinable
    func splashScreenSettingsRemoteLoad(
        period: String,
        serial: String?,
        completion: @escaping LoadCompletion<Result<SerialComponents.SerialStamped<String, [SplashScreenSettings]>, Error>>
    ) {
        let remoteLoad = nanoServiceComposer.composeSerialResultLoad(
            createRequest: { serial in
                
                try RequestFactory.createGetSplashScreenSettingsRequest(
                    serial: serial,
                    period: period
                )
            },
            mapResponse: { ResponseMapper.map(period, $0, $1) }
        )
        
        remoteLoad(serial) { completion($0); _ = remoteLoad }
    }
    
    typealias SplashScreenSettingsOutcome = CategorizedOutcome<String, SplashScreenSettings>
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func getSplashScreenImages(
        for outcome: SplashScreenSettingsOutcome,
        with getSplashScreenImage: @escaping GetSplashScreenImage,
        completion: @escaping (SplashScreenStorage?) -> Void
    ) {
        let imageLoader = BatchLoader(load: getSplashScreenImage)
        
        imageLoader.load(payloads: outcome.linksToLoad) {
            
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

// MARK: - Cache

typealias CodableSplashScreenStorage = CategorizedStorage<String, CodableSplashScreenSettings>

extension CodableSplashScreenSettings: Categorized {
    
    typealias Category = String
    
    var category: String { period }
}

extension RootViewModelFactory {
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashImagesCache() -> SplashScreenStorage? {
        
        guard let storage = model.localAgent.load(type: CodableSplashScreenStorage.self)
        else {
            cacheDebugLog(message: "No SplashScreenSettings.")
            return nil
        }
        
        cacheDebugLog(message: "Loaded SplashScreenSettings: \(String(describing: storage))")
        return storage.map { .init(codable: $0) }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func clearSplashImagesCache() {
        
        do {
            try model.localAgent.clear(type: CodableSplashScreenStorage.self)
            cacheDebugLog(message: "Cleared SplashImages cache.")
        } catch {
            errorLog(category: .cache, message: "Failed to clear SplashImages cache.")
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func cache(
        splashImages storage: SplashScreenStorage
    ) {
        let storage: CodableSplashScreenStorage = storage.map(CodableSplashScreenSettings.init)
        
        do {
            // storage holds serials for underlying data and does not have serial for itself
            try model.localAgent.update(with: storage, serial: nil, using: CategorizedStorage.merge)
        } catch {
            errorLog(category: .cache, message: "Failed to cache SplashImages.")
        }
    }
}

// MARK: - Adapters, Helpers

private extension ResponseMapper {
    
    static func map(
        _ period: String,
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> Result<SerialComponents.SerialStamped<String, [SplashScreenSettings]>, any Error> {
        
        return RemoteServices.ResponseMapper
            .mapGetSplashScreenSettingsResponse(data, httpURLResponse)
            .map {
                
                return .init(
                    value: $0.list.compactMap {
                        $0.settings(period: period)
                    },
                    serial: $0.serial)
            }
            .mapError { $0 }
    }
}

private extension CategorizedOutcome
where Item == SplashScreenSettings {
    
    var linksToLoad: [String] {
        
        guard let storage else { return [] }
        
        return storage.categories
            .compactMap { storage.items(for: $0) }
            .flatMap { $0 }
            .filter { $0.imageData == nil }
            .map(\.link)
    }
}

private extension CategorizedOutcome
where Category == String,
      Item == SplashScreenSettings {
    
    func transform(
        with outcome: Outcome<String, Data>
    ) -> SplashScreenStorage? {
        
        return storage?.map { setting in
            
            let imageData = outcome.storage[setting.link].imageData
            
            return .init(
                imageData: imageData,
                link: setting.link,
                period: setting.period
            )
        }
    }
}

private extension Optional where Wrapped == Data {
    
    var imageData: Result<Data, SplashScreenSettings.DataFailure> {
        
        map { .success($0) } ?? .failure(.init())
    }
}

// MARK: - Helpers

extension CategorizedStorage: CustomStringConvertible {
    
    public var description: String {
        
        let info = categories.map { ($0, items(for: $0)?.count ?? 0) }
        
        return "CategorizedStorage for \(info)"
    }
}

// MARK: - Codable (Caching)

private extension RemoteServices.ResponseMapper.SplashScreenSettings {
    
    func settings(
        period: String
    ) -> SplashScreenSettings? {
        
        return link.map { .init(imageData: nil, link: $0, period: period) }
    }
}

struct CodableSplashScreenSettings: Codable {
    
    let imageData: ImageData
    let link: String
    let period: String
    
    enum ImageData: Codable {
        
        case data(Data)
        case failure
        case none
    }
}

extension CodableSplashScreenSettings {
    
    var imageDataResult: Result<Data, SplashScreenSettings.DataFailure>? {
        
        switch imageData {
        case let .data(data): return .success(data)
        case .failure:        return .failure(.init())
        case .none:           return nil
        }
    }
}

private extension SplashScreenSettings {
    
    init(codable: CodableSplashScreenSettings) {
        
        self.init(
            imageData: codable.imageDataResult,
            link: codable.link,
            period: codable.period
        )
    }
}

private extension CodableSplashScreenSettings {
    
    init(_ settings: SplashScreenSettings) {
        
        self.init(
            imageData: settings._imageData,
            link: settings.link,
            period: settings.period
        )
    }
}

private extension SplashScreenSettings {
    
    var codable: CodableSplashScreenSettings {
        
        return .init(
            imageData: _imageData,
            link: link,
            period: category
        )
    }
    
    var _imageData: CodableSplashScreenSettings.ImageData {
        
        switch imageData {
        case .none:              return .none
        case .failure:           return .failure
        case let .success(data): return .data(data)
        }
    }
}
