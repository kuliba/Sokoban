//
//  MainSectionPromoViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI
import UIPrimitives
import Combine

//MARK: - ViewModel

extension MainSectionPromoView {
    
    class ViewModel: MainSectionViewModel, ObservableObject {
        
        override var type: MainSectionType { .promo }
        @Published var banners: [BannerViewModel]
        
        private let model: Model
        private let promoType: PromoType
        private var bindings = Set<AnyCancellable>()
        
        private var catalogBanners: CurrentValueSubject<[BannerCatalogListData], Never> {
            
            switch promoType {
            case .general: return model.catalogBanners
            }
        }
        
        init(banners: [BannerViewModel], model: Model = .emptyMock, promoType: PromoType) {
            
            self.banners = banners
            self.model = model
            self.promoType = promoType
            
            super.init()
        }

        convenience init(_ model: Model, promoType: PromoType = .general) {
            
            self.init(banners: [], model: model, promoType: promoType)
            bind()
        }
        
        enum PromoType {
            
            case general
        }

        private func bind() {
            
            catalogBanners
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] catalogBanners in
                    
                    let updated = Self.reduce(catalogBanners: catalogBanners,
                                              images: model.images.value,
                                              action: { [weak self] bannerAction in { self?.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: bannerAction)) }
                    })

                    updateBanners(updated)
                    
                    if let endpointsToDownload = Self.reduce(banners: banners) {
                        
                        for endpoint in endpointsToDownload {
                            
                            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: endpoint))
                        }
                    }
  
                }.store(in: &bindings)
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    for banner in banners {
                        
                        guard let endpoint = banner.endpoint,
                              let image = images[endpoint]?.image else {
                            continue
                        }
                        
                        withAnimation {
                            banner.image = .image(image)
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        private func updateBanners(_ updated: [BannerViewModel]) {
            
            switch promoType {
            case .general:
                
                withAnimation {
                    
                    banners = updated
                }
            }
        }
    }
}

extension MainSectionPromoView.ViewModel {
    
    static func reduce(catalogBanners: [BannerCatalogListData],
                       images: [String: ImageData],
                       action: @escaping (BannerAction) -> (() -> Void)) -> [BannerViewModel] {
        
        var result = [BannerViewModel]()
        
        for banner in catalogBanners {
            
            let image = images[banner.imageEndpoint]?.image
            if let bannerAction = banner.action {
                
                result.append(.init(with: banner, image: image, action: action(bannerAction)))
                
            } else {
                
                result.append(.init(with: banner, image: image))
            }
        }
        
        return result
    }
    
    static func reduce(banners: [BannerViewModel]) -> [String]? {
        
        let endpoints = banners.compactMap({ $0.endpoint })
        guard endpoints.isEmpty == false else {
            return nil
        }
        
        return endpoints
    }
}

extension MainSectionPromoView.ViewModel {
    
    class BannerViewModel: Identifiable, ObservableObject {
        
        let id: BannerCatalogListData.ID
        @Published var image: BannerImage
        let action: BannerAction
        
        var endpoint: String? {
            
            switch image {
            case let .endpoint(endpoint): return endpoint
            default: return nil
            }
        }

        init(id: BannerCatalogListData.ID, image: BannerImage, action: BannerAction) {
            
            self.id = id
            self.image = image
            self.action = action
        }
        
        convenience init(with bannerData: BannerCatalogListData,
                         image: Image? = nil,
                         action: (() -> Void)? = nil) {
            
            let bannerImage = BannerImage(endpoint: bannerData.imageEndpoint, image: image)
            let bannerAction: BannerAction = {
                guard let orderURL = bannerData.orderURL else { return .action(action ?? {})}
                
                return .init(link: orderURL, action: action)
            }()
            self.init(id: bannerData.id, image: bannerImage, action: bannerAction)
        }
        
        //MARK: Types
        
        enum BannerImage: Equatable {
            
            case endpoint(String)
            case image(Image)
            
            init(endpoint: String, image: Image?) {
                
                if let image = image {
                    
                    self = .image(image)
                    
                } else {
                    
                    self = .endpoint(endpoint)
                }
            }
        }
        
        enum BannerAction {
            
            case action(() -> Void)
            case link(URL)
            
            init(link: URL, action: (() -> Void)?) {
                
                if let action = action {
                    
                    self = .action(action)
                    
                } else {
                    
                    self = .link(link)
                }
            }
            
            init(action: @escaping () -> Void) {
                self = .action(action)
            }
        }
    }
}

//MARK: - View

struct MainSectionPromoView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.banners) { bannerViewModel in
                    
                    BannerView(viewModel: bannerViewModel)
                }
            }
        }
    }
    
    struct BannerView: View {
        
        @ObservedObject var viewModel: MainSectionPromoView.ViewModel.BannerViewModel
        
        var body: some View {
            
            switch viewModel.image {
            case .endpoint:
                
                Color.mainColorsGrayLightest
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 288, height: 124)
                    .shimmering()
                    .accessibilityIdentifier("placeholderBanner")
                
            case .image(let image):
                
                switch viewModel.action {
                case let .action(action):
                    Button(action: action) {
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                        
                    }
                    .buttonStyle(PushButtonStyle())
                    .accessibilityIdentifier("actionBanner")
                    
                case let .link(url):
                    Link(destination: url) {
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                        
                        
                    }
                    .buttonStyle(PushButtonStyle())
                    .accessibilityIdentifier("linkBanner")
                }
            }
        }
    }
}

//MARK: - Preview

struct MainSectionPromotionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionPromoView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 300))
            
            MainSectionPromoView.BannerView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

//MARK: - Preview Content

extension MainSectionPromoView.ViewModel {
    
    static let sample = MainSectionPromoView.ViewModel(banners: [.sample], promoType: .general)
}

extension MainSectionPromoView.ViewModel.BannerViewModel {
    
    static let sample = MainSectionPromoView.ViewModel.BannerViewModel(id: 0, image: .image(Image("Promo Banner Cashback")), action: .link(URL(string: "https://google.com")!))
}
