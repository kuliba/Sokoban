//
//  TransfersPromoDepositViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 11.01.2023.
//

import SwiftUI
import Combine
import Shimmer

// MARK: - ViewModel

extension TransfersPromoDepositView {
    
    class ViewModel {
        
        typealias DetailViewModel = TransfersDetailView.ViewModel.OptionDetailViewModel
        typealias DetailData = TransferAbroadResponseData.AdvantageTransferData.ContentData
        
        let logo: LogoViewModel
        let detailItems: [DetailViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model,
             logo: LogoViewModel,
             detailItems: [DetailViewModel]) {
            
            self.model = model
            self.logo = logo
            self.detailItems = detailItems
        }
        
        convenience init?(model: Model, countryId: String, bannerType: BannerActionType) {
            
            guard let bannersDetailData = model.transferAbroad.value?.bannersDetailList,
                  let itemData = bannersDetailData.first(where: {
                                    $0.type == bannerType && $0.countryId == countryId }),
                  let countryData = model.dictionaryCountry(for: countryId)
                    
            else { return nil }
            
            let images = model.images.value
            var imageDownloadList = [String]()
            
            let details = Self.reduce(data: itemData.list ?? [])
            
            self.init(
                model: model,
                
                logo: .init(icon: ImageStateViewModel.reduce(images: images,
                                                             md5hash: countryData.md5hash,
                                                             imagesDownloadList: &imageDownloadList),
                            title: itemData.title ?? "",
                            info: itemData.info ?? ""),
                detailItems: details)
           
            bind()
            
            if !imageDownloadList.isEmpty {
                model.action.send(
                    ModelAction.Dictionary.DownloadImages.Request(imagesIds: imageDownloadList))
            }
            
        }
        
        private func bind() {
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    guard !images.isEmpty else { return }
                    
                    if let newImg = ImageStateViewModel.updateImage(imgState: logo.icon, images: images) {
                        self.logo.icon = newImg
                    }
       
                }.store(in: &bindings)
        }
       
        static func reduce(data: [DetailData]) -> [DetailViewModel] {
            
            data.compactMap { item in
            
                guard let icon = DetailData.IconType(rawValue: item.iconType)?.icon else { return nil }
                return .init(icon: icon, title: item.title, description: item.description)
            }
        }
        
    }
}

extension TransfersPromoDepositView.ViewModel {
    
    class LogoViewModel: ObservableObject {
        
        @Published var icon: ImageStateViewModel
        let title: String
        let info: String
        
        init(icon: ImageStateViewModel, title: String, info: String) {
            self.title = title
            self.icon = icon
            self.info = info
        }
    }
    
}

// MARK: - View
        
struct TransfersPromoDepositView: View {
    
    let viewModel: TransfersPromoDepositView.ViewModel
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
       
        ScrollView(.vertical, showsIndicators: false) {
            
            Group {
                
                LogoView(viewModel: viewModel.logo)
                    .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    ForEach(viewModel.detailItems) { item in
                        TransfersDetailView.OptionDetailView(viewModel: item)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 53)
                .padding(.horizontal)
            }
            .readSize { contentHeight = $0.height }
        }
        .frame(height: UIScreen.main.bounds.height - 100 < contentHeight ? UIScreen.main.bounds.height - 100 : contentHeight)
      
    }
    
    struct LogoView: View {
        
        @ObservedObject var viewModel: TransfersPromoDepositView.ViewModel.LogoViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                switch viewModel.icon {
                case .placeholder:
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 64)
                        .shimmering(active: true, bounce: false)
                    
                case let .image(icon):
                
                    icon
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }
                
                Text(viewModel.title)
                    .font(.textH3M18240())
                    .foregroundColor(.mainColorsBlack)
                    .multilineTextAlignment(.center)
                    .padding(.top, 22)
                    .padding(.horizontal, 50)
                
                Text(viewModel.info)
                    .font(.textBodyMR14180())
                    .foregroundColor(.textPlaceholder)
                    .padding(.top, 12)
            }
        }
    }
  
}


// MARK: - Preview

struct TransfersPromoDepositView_Previews: PreviewProvider {
    static var previews: some View {
        TransfersPromoDepositView(
            viewModel: .init(model: .emptyMock,
                             logo: .init(icon: .image(Image("Armenia Flag")),
                                         title: "Больше возможностей при переводах в Армению",
                                         info: "Теперь до 1 000 000 ₽"),
                             detailItems: TransfersDetailView.ViewModel.sampleOptions))
            .previewLayout(.sizeThatFits)
    }
}


