//
//  TransfersDetailViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 25.11.2022.
//  Refactor by Dmitry Martynov on 29.12.2022
//

import SwiftUI
import Combine
import Shimmer

// MARK: - ViewModel

extension TransfersDetailView {
    
    class ViewModel: ObservableObject {
        
        typealias DetailData = TransferAbroadResponseData.DirectionDetailData
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var icon: ImageStateViewModel
        @Published var banksList: [TransfersBankViewModel]?
        
        let title: String
        let options: [OptionDetailViewModel]
        let transfersMoney: TransfersMoneyViewModel?
        let countryCode: String
        
        lazy var orderButton: TransfersButtonViewModel = .init(style: .gray) { [weak self] in
            self?.action.send(TransfersDetailAction.Button.Order.Tap())
        }
        
        lazy var transfersButton: TransfersButtonViewModel = .init(style: .red) { [weak self] in
            self?.action.send(TransfersDetailAction.Button.Transfers.Tap())
        }
        
        private var bindings = Set<AnyCancellable>()
        private let model: Model
        
        init(_ model: Model, icon: ImageStateViewModel, title: String, countryCode: String, transfersMoney: TransfersMoneyViewModel?, options: [OptionDetailViewModel], banksList: [TransfersBankViewModel]?) {
            
            self.model = model
            self.icon = icon
            self.title = title
            self.countryCode = countryCode
            self.transfersMoney = transfersMoney
            self.options = options
            self.banksList = banksList
        }
        
        convenience init?(_ model: Model, countryCode: String) {
            
            guard let dataList = model.transferAbroad.value?.directionsDetailList,
                  let data = dataList.first(where: { $0.code == countryCode}),
                  let countryData = model.dictionaryCountry(for: countryCode)
            else { return nil }
            
            var imageDownloadList = [String]()
            
            //main icon
            let icon = ImageStateViewModel.reduce(images: model.images.value,
                                                  md5hash: countryData.md5hash,
                                                  imagesDownloadList: &imageDownloadList)
            
            //Money
            var money: TransfersMoneyViewModel? = nil
            
            if let moneyData = data.transfersMoney {
                
                money = .init(icon: ImageStateViewModel.reduce(images: model.images.value,
                                                               md5hash: moneyData.md5hash,
                                                               imagesDownloadList: &imageDownloadList),
                              title: moneyData.title)
            }
            
            self.init(model,
                      icon: icon,
                      title: countryData.name,
                      countryCode: countryCode,
                      transfersMoney: money,
                      options: Self.createOptions(data: data),
                      banksList: Self.reduce(dataPromoBanks: data.banksList,
                                             banksDict: model.bankList.value,
                                             images: model.images.value,
                                             imageDownloadList: &imageDownloadList)
            )
            
            bind(dataBankList: data.banksList)
            
            if !imageDownloadList.isEmpty {
                model.action.send(ModelAction.Dictionary.DownloadImages.Request
                    .init(imagesIds: imageDownloadList))
            }
        }
        
        private func bind(dataBankList: [String]?) {
            
            model.bankList
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] bankDict in

                    guard !bankDict.isEmpty && self.banksList == nil else { return }
                    
                    var imageDownloadList = [String]()
                    self.banksList = Self.reduce(dataPromoBanks: dataBankList,
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
                    
                    //mainIcon
                    if let newImg = ImageStateViewModel.updateImage(imgState: self.icon, images: images) {
                        self.icon = newImg
                    }
                    
                    //money
                    if let newImg = ImageStateViewModel.updateImage(imgState: self.transfersMoney?.icon, images: images) {
                        self.transfersMoney?.icon = newImg
                    }

                    //Banks
                    for item in self.banksList ?? [] {
                    
                        if let newImg = ImageStateViewModel.updateImage(imgState: item.icon, images: images) {
                            item.icon = newImg
                        }
                    }

                }.store(in: &bindings)
        }
        
    }
}

extension TransfersDetailView.ViewModel {
    
    static func createOptions(data: DetailData) -> [OptionDetailViewModel] {

        return [
            .init(icon: .ic24Percent,
                  title: data.commission.title,
                  description: data.commission.description),
            .init(icon: .ic24ArrowUpRight,
                  title: data.sending.title,
                  description: data.sending.description),
            .init(icon: .ic24ArrowDownLeft,
                  title: data.receiving.title,
                  description: data.receiving.description)
        ]
    }
    
    static func reduce(dataPromoBanks: [String]?,
                       banksDict: [BankData],
                       images: [String: ImageData],
                       imageDownloadList: inout [String]) -> [TransfersBankViewModel]? {
        
        guard let dataBanks = dataPromoBanks else { return nil }
        
        let banksList = dataBanks.flatMap { item in
            banksDict.filter { $0.memberId == item }
        }
        
        return banksList.map {
            TransfersBankViewModel(title: $0.memberNameRus,
                                   memberId: $0.memberId,
                                   icon: ImageStateViewModel.reduce(images: images,
                                                                    md5hash: $0.md5hash,
                                                                    imagesDownloadList: &imageDownloadList))
        }
    }
}

extension TransfersDetailView.ViewModel {
    
    class TransfersMoneyViewModel: ObservableObject {
        
        @Published var icon: ImageStateViewModel
        
        let title: String
        
        init(icon: ImageStateViewModel, title: String) {
            
            self.icon = icon
            self.title = title
        }
    }
    
    struct TransfersButtonViewModel {
        
        let style: Style
        let action: () -> Void
        
        enum Style {
            
            case gray
            case red
            
            var title: String {
                
                switch self {
                case .gray: return "Заказать карту"
                case .red: return "Войти и перевести"
                }
            }
            
            var color: Color {
                
                switch self {
                case .gray: return .mainColorsGrayLightest
                case .red: return .mainColorsRed
                }
            }
            
            var textColor: Color {
                
                switch self {
                case .gray: return .mainColorsBlack
                case .red: return .mainColorsWhite
                }
            }
        }
    }
    
    struct OptionDetailViewModel: Identifiable {
        
        var id: String { title }
        
        var alignment: VerticalAlignment {
            
            if title.count + description.count > 30 {
                return .top
            } else {
                return .center
            }
        }
        
        let icon: Image
        let title: String
        let description: String
    }

    class TransfersBankViewModel: ObservableObject, Identifiable {
        
        @Published var icon: ImageStateViewModel
        
        let title: String
        let memberId: String
        
        init(title: String, memberId: String, icon: ImageStateViewModel) {
            
            self.title = title
            self.memberId = memberId
            self.icon = icon
        }
    }
}

// MARK: - View

struct TransfersDetailView: View {
    
    @ObservedObject var viewModel: TransfersDetailView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 20) {
                
                switch viewModel.icon {
                case .placeholder:

                    Circle()
                        .foregroundColor(.mainColorsGrayMedium.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .shimmering(active: true, bounce: false)

                case let .image(icon):

                    icon
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                }
                    
                Text(viewModel.title.capitalized)
                    .font(.textH3M18240())
                    .foregroundColor(.mainColorsBlack)
            }
            
            if let money = viewModel.transfersMoney {
                
                TransfersMoneyButtonView(viewModel: money)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 24) {
                
                ForEach(viewModel.options) { option in
                    OptionDetailView(viewModel: option)
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            .padding(.top, 32)
            
            if let items = viewModel.banksList {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 26) {
                        
                        ForEach(items) { item in
                            TransfersBankView(viewModel: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            
            VStack(spacing: 8) {
                
                TransfersButtonView(viewModel: viewModel.orderButton)
                TransfersButtonView(viewModel: viewModel.transfersButton)
                
            }.padding()
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .padding(.top, 10)
        .padding(.bottom, 40)
    }
}

extension TransfersDetailView {
    
    struct TransfersMoneyButtonView: View {
        
        @ObservedObject var viewModel: TransfersDetailView.ViewModel.TransfersMoneyViewModel
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                switch viewModel.icon {
                case .placeholder:
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayMedium.opacity(0.6))
                        .frame(width: 24, height: 24)
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
            .frame(height: 40)
            .padding(.horizontal, 8)
            .background(Color.mainColorsGrayLightest.cornerRadius(90))
        }
    }
    
    struct TransfersButtonView: View {
        
        let viewModel: TransfersDetailView.ViewModel.TransfersButtonViewModel
        
        private var title: String { viewModel.style.title }
        private var color: Color { viewModel.style.color }
        private var textColor: Color { viewModel.style.textColor }
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.textH3SB18240())
                        .foregroundColor(textColor)
                }
                
            }.frame(height: 56)
        }
    }
    
    struct OptionDetailView: View {
        
        let viewModel: TransfersDetailView.ViewModel.OptionDetailViewModel
        
        var body: some View {
            
            HStack(alignment: viewModel.alignment, spacing: 16) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    viewModel.icon
                        .renderingMode(.original)
                }
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.mainColorsBlack) +
                
                Text(viewModel.description)
                    .font(.textH4R16240())
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }

    struct TransfersBankView: View {
        
        @ObservedObject var viewModel: ViewModel.TransfersBankViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                switch viewModel.icon {
                case .placeholder:
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayMedium.opacity(0.6))
                        .frame(width: 56, height: 56)
                        .shimmering(active: true, bounce: false)
                    
                case let .image(icon):
                    
                    icon
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                }
                
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsBlack)
            }
            
        }
    }
}

// MARK: - Action

enum TransfersDetailAction {
    
    enum Button {
        
        enum Order {
            
            struct Tap: Action {}
        }
        
        enum Transfers {
            
            struct Tap: Action {}
        }
    }
}

extension TransfersDetailView.ViewModel {
    
    static let sampleOptions: [OptionDetailViewModel] =
        [
        .init(
            icon: .ic24Percent,
            title: "Комиссия — 1%",
            description: "— зависит от валют перевода:\nВалюты отправки и получения разные — комиссия 0% по курсу конвертации Contact"
        ),
        .init(
            icon: .ic24ArrowUpRight,
            title: "Отправка",
            description: " — по номеру телефона получателя до 500 000 ₽ за операцию / в день / в месяц"
        ),
        .init(
            icon: .ic24ArrowDownLeft,
            title: "Получение",
            description: " – на карту/счет получателя в банках-партнерах: "
        )
    ]
    
    static let sampleBankList: [TransfersBankViewModel] =
        [
        .init(title: "Bank1",
                          memberId: "01",
                          icon: .placeholder(nil)),
        .init(title: "Bank2",
              memberId: "02",
              icon: .placeholder(nil)),
        .init(title: "Bank3",
              memberId: "03",
              icon: .placeholder(nil)),
        .init(title: "Bank4",
              memberId: "04",
              icon: .placeholder(nil))]
}

// MARK: - Preview

struct TransfersDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TransfersDetailView(viewModel: .init(.emptyMock,
                                             icon: .image(Image("Armenia Flag")),
                                             title: "Армения",
                                             countryCode: "AM",
                                             transfersMoney: .init(icon: .placeholder(nil),
                                                                   title: "Денежные переводы МИГ"),
                                             options: TransfersDetailView.ViewModel.sampleOptions,
                                             banksList: TransfersDetailView.ViewModel.sampleBankList))
            .previewLayout(.sizeThatFits)
    }
}
