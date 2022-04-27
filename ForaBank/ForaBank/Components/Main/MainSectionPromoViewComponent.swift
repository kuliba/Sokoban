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
    
    class ViewModel: MainSectionViewModel {
        
        override var type: MainSectionType { .promo }
        @Published var items: [PromotionViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(items: [PromotionViewModel], model: Model = .emptyMock) {
            
            self.items = items
            self.model = model
            super.init()
        }
        
        init(_ model: Model) {
            
            self.items = []
            self.model = model
            super.init()
        }
        
        func bind() {
            
            model.catalogBanners
                .receive(on: DispatchQueue.main)
                .sink { [unowned self]  banners in
                    
                    var updated = [PromotionViewModel]()
                    
                    for banner in banners {
                        
                        let bannerViewModel = PromotionViewModel(with: banner, action: {})
                        updated.append(bannerViewModel)
                    }
                    
                    items = updated
                    
                }.store(in: &bindings)
        }
    }
    
    class PromotionViewModel: Identifiable, ObservableObject {

        let id: String
        @Published var image: Image?
        let action: () -> Void

        internal init(id: String = UUID().uuidString, image: Image?, action: @escaping () -> Void) {

            self.id = id
            self.image = image
            self.action = action
        }
        
        convenience init(with bannerData: BannerCatalogListData, action: @escaping () -> Void) {
            
            self.init(id: bannerData.imageLink, image: nil, action: action)
            
        }
    }
}

//MARK: - View

struct MainSectionPromoView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.items) { promotionViewModel in
                    
                    Button {
                        
                        promotionViewModel.action()
                        
                    } label: {
                        
                        promotionViewModel.image
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    struct BannerView: View {
        
        @ObservedObject var viewModel: PromotionViewModel
        
        var body: some View {
            
            if let image = viewModel.image {
                
                Button(action: viewModel.action) {
                    
                    image
                        .frame(width: 288, height: 124)
                        .cornerRadius(12)
                }
                
            } else {
                
                Color(hex: "F6F6F7")
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 288, height: 124)
                    .shimmering(active: true, bounce: true)
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
            
            MainSectionPromoView.BannerView(viewModel: .init(id: UUID().uuidString, image: nil, action: {}))
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

//MARK: - Preview Content

extension MainSectionPromoView.ViewModel {

    static let sample = MainSectionPromoView.ViewModel(items: [.init(image: Image("Promo Banner Cashback"), action: {}), .init(image: Image("Promo Banner Mig"), action: {})])
}
