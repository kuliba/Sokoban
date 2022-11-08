//
//  MainSectionPromoViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI
import Shimmer
import Combine

//MARK: - ViewModel

extension MainSectionPromoView {
    
    class ViewModel: MainSectionViewModel, ObservableObject {
        
        override var type: MainSectionType { .promo }
        @Published var banners: [BannerViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(banners: [BannerViewModel], model: Model = .emptyMock) {
            
            self.banners = banners
            self.model = model
            super.init()
        }
        
        init(_ model: Model) {
            
            self.banners = []
            self.model = model
            super.init()
            
            bind()
        }
        
        private func bind() {
            
            model.catalogBanners
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] catalogBanners in
                    
                    var updated = [BannerViewModel]()
                    
                    for banner in catalogBanners {
                        
                        if let bannerViewModel = banners.first(where: { $0.id == banner.id}) {
                            
                            switch banner.action {
                            case let payload as BannerActionDepositOpen:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionDepositsList:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionMigTransfer:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionContactTransfer:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            default: break
                            }
                            
                            updated.append(bannerViewModel)
                            
                            guard bannerViewModel.image == nil else { continue }
                            
                            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: banner.imageEndpoint))
                            
                        } else {
                            
                            let bannerViewModel = BannerViewModel(with: banner)
                            
                            switch banner.action {
                            case let payload as BannerActionDepositOpen:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionDepositsList:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionMigTransfer:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            case let payload as BannerActionContactTransfer:
                                let action: () -> Void = { self.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: payload))}
                                bannerViewModel.showAction = action
                                
                            default: break
                            }
                            
                            updated.append(bannerViewModel)
                            
                            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: banner.imageEndpoint))
                        }
                    }
                    
                    withAnimation {
                        
                        banners = updated
                    }
                    
                }.store(in: &bindings)
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.General.DownloadImage.Response:
                        switch payload.result {
                        case .success(let data):
                            
                            
                            if let image = Image(data: data) {
                                
                                let bannersFilter = banners.filter({$0.image == .endpoint(payload.endpoint)})
                                
                                withAnimation {
                                    
                                    for banner in bannersFilter {
                                        
                                        banner.image = .image(image)
                                    }
                                }
                                
                            } else {
                                
                                // remove banner if creating image from data failed
                                withAnimation {
                                    
                                    banners = banners.filter{ $0.image != .endpoint(payload.endpoint) }
                                }
                            }
                            
                        case .failure:
                            // remove banner if image downloading failed
                            withAnimation {
                                
                                banners = banners.filter{ $0.image != .endpoint(payload.endpoint) }
                            }
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension MainSectionPromoView.ViewModel {
    
    class BannerViewModel: Identifiable, ObservableObject {
        
        let id: BannerCatalogListData.ID
        @Published var image: BannerImage
        let url: URL
        var showAction: () -> Void?
        let openLink: Bool
        
        enum BannerImage: Equatable {
            
            case endpoint(String)
            case image(Image)
        }
        
        internal init(id: Int, image: BannerImage, url: URL, showAction: @escaping () -> Void, openLink: Bool) {
            
            self.id = id
            self.image = image
            self.url = url
            self.showAction = showAction
            self.openLink = openLink
        }
        
        convenience init(with bannerData: BannerCatalogListData) {
            
            let image: BannerImage = .endpoint(bannerData.imageEndpoint)
            let openLink = { bannerData.action != nil }()
            self.init(id: bannerData.id, image: image, url: bannerData.orderURL, showAction: {}, openLink: openLink)
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
            .padding(.horizontal, 20)
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
                    .shimmering(active: true, bounce: false)
                
            case .image(let image):
                
                if viewModel.openLink {
                    
                    Button{
                        viewModel.showAction()
                        
                    } label: {
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                        
                    }.buttonStyle(PushButtonStyle())
                    
                } else {
                    
                    Link(destination: viewModel.url) {
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                        
                    }.buttonStyle(PushButtonStyle())
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
            
            MainSectionPromoView.BannerView(viewModel: .init(id: 0, image: .image(.ic48Abroad), url: URL(string: "https://google.com")!, showAction: {}, openLink: true))
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

//MARK: - Preview Content

extension MainSectionPromoView.ViewModel {
    
    static let sample = MainSectionPromoView.ViewModel(banners: [.init(id: 1, image: .image(Image("Promo Banner Cashback")), url: URL(string: "https://google.com")!, showAction: {}, openLink: true), .init(id: 0, image: .endpoint(""), url: URL(string: "https://google.com")!, showAction: {}, openLink: true)])
}
