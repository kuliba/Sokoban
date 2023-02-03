//
//  TransfersPromoDetailViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 29.11.2022.
//  Refactor by Dmitry Martynov on 29.12.2022
//

import SwiftUI
import Combine
import Shimmer

// MARK: - ViewModel

extension TransfersPromoDetailView {
    
    class ViewModel: ObservableObject {
        
        typealias ComponentViewModel = TransfersDetailView.ViewModel
        
        let logo: LogoViewModel
        let transfersMoney: TransfersMoneyViewModel?
        let freeCard: TransfersFreeCardViewModel?
        let infoViewModel: TransfersPromoViewModel
        let termsViewModel: TransfersPromoViewModel
        let advantagesItems: [AdvantagesItemViewModel]
        @Published var banks: [ComponentViewModel.TransfersBankViewModel]?
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model,
             logo: LogoViewModel,
             transfersMoney: TransfersMoneyViewModel?,
             freeCardViewModel: TransfersFreeCardViewModel?,
             infoViewModel: TransfersPromoViewModel,
             termsViewModel: TransfersPromoViewModel,
             advantagesItems: [AdvantagesItemViewModel],
             banks: [ComponentViewModel.TransfersBankViewModel]?) {
            
            self.model = model
            self.logo = logo
            self.transfersMoney = transfersMoney
            self.freeCard = freeCardViewModel
            self.infoViewModel = infoViewModel
            self.termsViewModel = termsViewModel
            self.advantagesItems = advantagesItems
            self.banks = banks
        }
        
        convenience init?(model: Model, countryId: String, bannerType: BannerActionType) {
            
            guard let bannersDetailData = model.transferAbroad.value?.bannersDetailList,
                  let itemData = bannersDetailData.first(where: {
                                    $0.type == bannerType && $0.countryId == countryId }),
                  let countryData = model.dictionaryCountry(for: countryId)
                    
            else { return nil }
            
            let images = model.images.value
            var imageDownloadList = [String]()
            
            let advantages = TransfersAdvantagesView.ViewModel.reduce(data: itemData.advantages ?? [])
            
            self.init(
                model: model,
                
                logo: .init(icon: ImageStateViewModel.reduce(images: images,
                                                             md5hash: countryData.md5hash,
                                                             imagesDownloadList: &imageDownloadList),
                            title: countryData.name.capitalized),
                
                transfersMoney: .init(icon: ImageStateViewModel.reduce(images: images,
                                                                       md5hash: itemData.transfersMoney?.md5hash,
                                                                       imagesDownloadList: &imageDownloadList),
                                      title: itemData.transfersMoney?.title),
                
                freeCardViewModel: .init(icon: ImageStateViewModel.reduce(images: images,
                                                                    md5hash: itemData.freeCard?.md5hash,
                                                                    imagesDownloadList: &imageDownloadList),
                                         title: itemData.freeCard?.title),
                
                infoViewModel: Self.reduce(dataPromo: itemData.promoInfo ?? []),
                termsViewModel: Self.reduce(dataPromo: itemData.promoTerms ?? []),
                advantagesItems: advantages,
                
                banks: ComponentViewModel.reduce(dataPromoBanks: itemData.banksList,
                                                 banksDict: model.bankList.value,
                                                 images: model.images.value,
                                                 imageDownloadList: &imageDownloadList))
           
            bind(dataBankList: itemData.banksList)
            
            if !imageDownloadList.isEmpty {
                model.action.send(
                    ModelAction.Dictionary.DownloadImages.Request(imagesIds: imageDownloadList))
            }
            
        }
        
        private func bind(dataBankList: [String]?) {
            
            model.bankList
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] bankDict in

                    guard !bankDict.isEmpty && self.banks == nil else { return }
                    
                    var imageDownloadList = [String]()
                    self.banks = ComponentViewModel.reduce(dataPromoBanks: dataBankList,
                                                               banksDict: bankDict,
                                                               images: model.images.value,
                                                               imageDownloadList: &imageDownloadList)
                    
                    if !imageDownloadList.isEmpty {
                        model.action.send(ModelAction.Dictionary.DownloadImages.Request
                            .init(imagesIds: imageDownloadList))
                    }

                }.store(in: &bindings)
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    guard !images.isEmpty else { return }
                    
                    if let newImg = ImageStateViewModel.updateImage(imgState: logo.icon, images: images) {
                        self.logo.icon = newImg
                    }
                           
                    if let newImg = ImageStateViewModel.updateImage(imgState: transfersMoney?.icon, images: images) {
                        self.transfersMoney?.icon = newImg
                    }
                    
                    if let newImg = ImageStateViewModel.updateImage(imgState: freeCard?.icon, images: images) {
                        self.freeCard?.icon = newImg
                    }
                    
                    //Banks
                    for item in self.banks ?? [] {
                    
                        if let newImg = ImageStateViewModel.updateImage(imgState: item.icon, images: images) {
                            item.icon = newImg
                        }
                    }
       
                }.store(in: &bindings)
        }
        
        private static func reduce(dataPromo: [String]) -> TransfersPromoViewModel {
            
            .init(items: dataPromo.map { TransfersPromoViewModel.ItemsViewModel(title: $0) })
        }
        
    }
}

extension TransfersPromoDetailView.ViewModel {
    
    class LogoViewModel: ObservableObject {
        
        @Published var icon: ImageStateViewModel
        let title: String
        
        init(icon: ImageStateViewModel, title: String) {
            self.title = title
            self.icon = icon
        }
    }
    
    class TransfersMoneyViewModel: ObservableObject {
        
        @Published var icon: ImageStateViewModel
        let title: String
        
        init(icon: ImageStateViewModel, title: String) {
            self.title = title
            self.icon = icon
        }
        
        convenience init?(icon: ImageStateViewModel, title: String?) {
            guard let title = title else { return nil }
            self.init(icon: icon, title: title)
        }
        
    }
    
    class TransfersFreeCardViewModel: ObservableObject {
        
        @Published var icon: ImageStateViewModel
        let title: String
        
        init(icon: ImageStateViewModel, title: String) {
            self.title = title
            self.icon = icon
        }
        
        convenience init?(icon: ImageStateViewModel, title: String?) {
            guard let title = title else { return nil }
            self.init(icon: icon, title: title)
        }
    }
    
    struct TransfersPromoViewModel {
        
        let items: [ItemsViewModel]
    
        struct ItemsViewModel: Identifiable {
        
            var id: String { title }
            let title: String
        }
    }
}

// MARK: - View
        
struct TransfersPromoDetailView: View {
    
    @ObservedObject var viewModel: TransfersPromoDetailView.ViewModel
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                LogoView(viewModel: viewModel.logo)
                    .padding(.top, 10)
                
                if let viewModel = viewModel.transfersMoney {
                    TransfersMoneyView(viewModel: viewModel)
                            .padding()
                }
                
                TransfersPromoInfoView(viewModel: viewModel.infoViewModel)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                VStack(spacing: 24) {
                    
                    if let viewModel = viewModel.freeCard {
                        TransfersFreeCardView(viewModel: viewModel)
                    }
                    
                    ZStack(alignment: .leading) {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(.mainColorsGrayLightest)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            ForEach(viewModel.advantagesItems) { item in
                                AdvantagesItemView(viewModel: item)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        
                    }.fixedSize(horizontal: false, vertical: true)
                    
                }.padding()
                
                if let bankList = viewModel.banks {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 26) {
                            
                            ForEach(bankList) { item in
                                TransfersDetailView.TransfersBankView(viewModel: item)
                            }
                            
                        }.padding()
                    }
                }
                
                TransfersPromoTermView(viewModel: viewModel.termsViewModel)
                    .padding()
                
                Spacer()
            }
        }
    }
}

extension TransfersPromoDetailView {
    
    struct LogoView: View {
        
        @ObservedObject var viewModel: TransfersPromoDetailView.ViewModel.LogoViewModel
        
        var body: some View {
            
            VStack(spacing: 20) {
                
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
            }
        }
    }
    
    struct TransfersMoneyView: View {
        
        @ObservedObject var viewModel: TransfersPromoDetailView.ViewModel.TransfersMoneyViewModel
        
        var body: some View {
                
            ZStack {
                    
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.mainColorsGrayLightest)
                    
                HStack(spacing: 8) {
                        
                    switch viewModel.icon {
                    case .placeholder:
                            
                        Circle()
                            .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                            .frame(width: 24)
                            .shimmering(active: true, bounce: false)
                            
                    case let .image(icon):
                        
                        icon
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    }
                        
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsBlack)
                }
                
            }.frame(width: 233, height: 40)
           
        }
    }
    
    struct TransfersPromoInfoView: View {
        
        let viewModel: TransfersPromoDetailView.ViewModel.TransfersPromoViewModel
        
        var body: some View {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    ForEach(viewModel.items) { item in
                        
                        HStack(alignment: .top) {
                            
                            Text("•")
                            
                            Text(item.title)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                    
                        }
                        .foregroundColor(.mainColorsBlack)
                        .font(.textH4R16240())
                        
                    }
                    
                }.padding(.horizontal, 8)
                
                Spacer()
            }
        }
    }
    
    struct TransfersFreeCardView: View {
        
        @ObservedObject var viewModel: TransfersPromoDetailView.ViewModel.TransfersFreeCardViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(spacing: 42) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsBlack)
                    
                    VStack {
                        
                        Spacer()
                        
                        switch viewModel.icon {
                        case .placeholder:
                            
                            Rectangle()
                                .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                                .frame(width: 62, height: 82)
                                .shimmering(active: true, bounce: false)
                            
                        case let .image(icon):
                        
                            icon
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 62, height: 82)
                        }
                    }
                }.padding(.horizontal, 16)
                
            }.frame(height: 96)
        }
    }
    
    struct TransfersPromoTermView: View {
        
        let viewModel: TransfersPromoDetailView.ViewModel.TransfersPromoViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    ForEach(viewModel.items) { item in
                        
                        Text(item.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
        }
    }
}

extension TransfersPromoDetailView.ViewModel {
    
    static let sampleInfoItems: [TransfersPromoViewModel.ItemsViewModel] = [
        
        .init(title: "Соверши свой первый перевод в Армению в приложении Фора-Банка*"),
        .init(title: "Получи кешбэк до 1 000 ₽*")]
    
    static let sampleTermsItems: [TransfersPromoViewModel.ItemsViewModel] = [
        
        .init(title: "*Акция «Кешбэк до 1000 руб. за первый перевод» – стимулирующее мероприятие, не является лотереей. Период проведения акции «Кешбэк до 1000 руб. за первый перевод» с 01 ноября 2022 по 31 января 2023 года. Информацию об организаторе акции, о правилах, порядке, сроках и месте ее проведения можно узнать на официальном сайте www.forabank.ru и в офисах АКБ «ФОРА-БАНК» (АО)."),
        .init(title: "** Участник Акции имеет право заключить с банком договор банковского счета с использованием карты МИР по тарифному плану «МИГ» или «Все включено-Промо» с бесплатным обслуживанием."),
        .init(title: "*** Банк выплачивает Участнику Акции кешбэк в размере 100% от суммы комиссии за первый перевод, но не более 1000 рублей.")]
}

// MARK: - Preview

struct TransfersPromoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TransfersPromoDetailView(
            viewModel: .init(model: .emptyMock,
                             logo: .init(icon: .image(Image("Armenia Flag")),
                                         title: "Армения"),
                             transfersMoney: .init(icon: .image(Image("Transfers MIG")),
                                                   title: "Денежные переводы МИГ") ,
                             freeCardViewModel: .init(icon: .image(Image("Free MIG")),
                                                      title: "Бесплатная** карта с кешбэком «Всё включено» МИР для участников акции"),
                             infoViewModel: .init(items: TransfersPromoDetailView.ViewModel.sampleInfoItems),
                             termsViewModel: .init(items: TransfersPromoDetailView.ViewModel.sampleTermsItems),
                                                  advantagesItems: TransfersAdvantagesView.ViewModel.sampleItems,
                                                  banks: TransfersDetailView.ViewModel.sampleBankList))
            .previewLayout(.sizeThatFits)
    }
}


