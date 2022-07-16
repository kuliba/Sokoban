//
//  OfferProductViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension OfferProductView {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        private var bindings = Set<AnyCancellable>()
        
        let id: Int?
        let title: String
        let subtitle: [String]
        @Published var image: ImageData
        @Published var infoButton: InfoButton?
        let orderButton: OrderButton
        var conditionViewModel: ConditionViewModel? = nil
        let design: Design
        var additionalCondition: AdditionalCondition? = nil
        @Published var isShowSheet: Bool = false
        
        internal init(id: Int, title: String, subtitle: [String], image: ImageData, infoButton: InfoButton, orderButton: OrderButton, conditionViewModel: ConditionViewModel, design: Design, additionalCondition: AdditionalCondition?) {
            
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.infoButton = infoButton
            self.orderButton = orderButton
            self.conditionViewModel = conditionViewModel
            self.design = design
            self.additionalCondition = additionalCondition
        }
        
        init(with product: CatalogProductData) {
            
            self.id = product.id
            self.title = product.name
            self.subtitle = product.description
            self.image = .endpoint(product.imageEndpoint)
            self.orderButton = OrderButton(url: product.orderURL)
            self.design = .init(background: .mainColorsBlack, textColor: .mainColorsWhite)
            self.infoButton = createInfoButton(with: product.infoURL)
        }
        
        init(with deposit: DepositProductData) {
            
            self.id = deposit.depositProductID
            self.title = deposit.name
            self.conditionViewModel = .init(percent: "\(deposit.generalСondition.maxRate)", amount: "\(deposit.generalСondition.minSum.currencyFormatter(symbol: "RUB"))", date: "\(deposit.generalСondition.maxTermTxt)")
            self.subtitle = deposit.generalСondition.generalTxtСondition
            self.image = .endpoint(deposit.generalСondition.imageLink)
            self.orderButton = OrderButton(url: .init(string: "https://www.forabank.ru")!)
            self.design = .init(background: deposit.generalСondition.design.background[0].color, textColor: deposit.generalСondition.design.textColor[0].color)
            self.additionalCondition = .init(desc: descriptionReduce(with: deposit.detailedСonditions))
            bind()
            self.infoButton = createInfoButton(with: .init(string: "https://www.forabank.ru"))
        }
        
        struct AdditionalCondition {
            
            let title: String = "Дополнительные условия"
            let desc: [Description]
            
            struct Description: Hashable {
                
                let desc: String
                let enable: Bool
            }
        }
        
        enum ImageData {
            
            case endpoint(String)
            case image(Image)
        }
        
        struct InfoButton {
            
            let title: String = "Допол.\nусловия"
            let icon: Image = .ic24Info
            let url: URL
            var action: () -> Void
            
        }
        
        struct Design {
            
            let background: Color
            let textColor: Color
        }
        
        struct ConditionViewModel {
            
            let percent: String
            let amount: String
            let date: String
            
            var percentViewModel: String {
                "До \(percent) %"
            }
            
            var amountViewModel: String {
                "От \(amount)"
            }
        }
        
        struct OrderButton {
            
            let title: String = "Продолжить"
            let url: URL
        }
        
        enum ModelAction {
            
            struct OpenDetail: Action {}
        }
        
        func bind() {
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ModelAction.OpenDetail:
                        self.action.send(OperationDetailViewModelAction.Dismiss())
                        
                    default: break
                    }
                }.store(in: &bindings)
        }
        
        private func createInfoButton(with url: URL?) -> InfoButton? {

           guard let url = url else {
              return nil
           }

            return InfoButton(url: url, action: { [weak self] in
                            self?.action.send(OpenDepositViewModel.ModelActionOpenDeposit.ButtonTapped())
                        })
        }

    }
}

extension OfferProductView.ViewModel {
    
    func descriptionReduce(with desc: [DepositProductData.DetailedСondition]) -> [AdditionalCondition.Description] {
        
        var description: [AdditionalCondition.Description] = []
        
        for condition in desc {
            
            description.append(.init(desc: condition.desc, enable: condition.enable))
        }
        
        return description
    }
}

//MARK: - View

struct OfferProductView: View {
    
    @ObservedObject var viewModel: OfferProductView.ViewModel
    
    var body: some View {
        
        ZStack {
            
            viewModel.design.background
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .font(.textH0B32402())
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.design.textColor)
                    .padding(.top, 32)
                
                if let conditionViewModel = viewModel.conditionViewModel {
                    
                    ConditionView(viewModel: conditionViewModel, color: viewModel.design.textColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    ForEach(viewModel.subtitle, id: \.self) { line in
                        
                        HStack(alignment: .top, spacing: 10) {
                            
                            Circle()
                                .foregroundColor(viewModel.design.textColor)
                                .frame(width: 5, height: 5)
                                .padding(.leading, 10)
                                .padding(.top, 7)
                            
                            Text(line)
                                .font(.textBodyMR14200())
                                .foregroundColor(viewModel.design.textColor)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 24)
                
                switch viewModel.image {
                case .image(let image):
                    image
                        .resizable()
                        .frame(height: 236)
                        .cornerRadius(12)
                        .padding(.top, 24)
                    
                case .endpoint:
                    Color
                        .mainColorsGrayMedium
                        .opacity(0.5)
                        .frame(height: 236)
                        .cornerRadius(12)
                        .padding(.top, 20)
                }
                
                HStack(alignment: .center, spacing: 20) {
                    
                    OfferProductView.InfoButtonView(viewModel: viewModel, color: viewModel.design.textColor)
                    
                    Spacer()
                    
                    OfferProductView.OrderButtonView(viewModel: viewModel)
                }
                .frame(height: 48)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
    }
    
    struct ConditionView: View {
        
        let viewModel: OfferProductView.ViewModel.ConditionViewModel
        
        let color: Color
        
        var body: some View {
            
            HStack(spacing: 16) {
                
                Text(viewModel.percentViewModel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.white)
                    .background(Color.mainColorsRed)
                    .cornerRadius(4)
                    .font(.system(size: 14))
                
                Text(viewModel.amountViewModel)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                color
                    .frame(width: 1, alignment: .center)
                    .padding(.vertical, 3)
                
                Text(viewModel.date)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
            }
            .frame(height: 24, alignment: .leading)
            .padding(.top, 24)
        }
    }
    
    struct InfoButtonView: View {
        
        let viewModel: OfferProductView.ViewModel
        
        let color: Color
        
        var body: some View {
            
            if let infoButton = viewModel.infoButton {
                
                Button {
                    
                    infoButton.action()
                    
                } label: {
                    
                    HStack {
                        
                        infoButton.icon
                            .foregroundColor(color)
                        
                        Text(infoButton.title)
                            .foregroundColor(color)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
    
    struct OrderButtonView: View {
        
        let viewModel: OfferProductView.ViewModel
        
        var body: some View {
            
            if #available(iOS 14.0, *) {
                
                //                Link(destination: viewModel.url) {
                //
                //                    Text(viewModel.title)
                //                        .foregroundColor(.textWhite)
                //                        .padding(.vertical, 12)
                //                        .frame(width: 166)
                //                        .background(Color.buttonPrimary)
                //                        .cornerRadius(8)
                //                }
                if let id = viewModel.id {
                    NavigationLink(destination: ProductDetailView(viewModel: .init(depositId: id))) {
                        Text(viewModel.orderButton.title)
                            .foregroundColor(.textWhite)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 17)
                            .background(Color.buttonPrimary)
                            .cornerRadius(8)
                    }
                }
                
            } else {
                
                Button{
                    
                    UIApplication.shared.open(viewModel.orderButton.url)
                    
                } label: {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textWhite)
                        .padding(.vertical, 12)
                        .frame(width: 166)
                        .background(Color.buttonPrimary)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    struct DetailConditionView: View {
        
        let viewModel: OfferProductView.ViewModel.AdditionalCondition
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    ForEach(viewModel.desc.indices, id:\.self ){ index in
                        
                        HStack(alignment: .top, spacing: 15) {
                            
                            if viewModel.desc[index].enable {
                                
                                Image.ic24Check
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .top)
                                    .foregroundColor(Color.green)
                                    .padding(.top, 5)
                                
                                Text(viewModel.desc[index].desc)
                                    .foregroundColor(.mainColorsBlack)

                            } else {
                                
                                Image.ic24Close
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .top)
                                    .foregroundColor(.mainColorsGray)
                                    .padding(.top, 5)
                                
                                Text(viewModel.desc[index].desc)
                                    .foregroundColor(.mainColorsGray)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

//MARK: - Preview

struct OfferProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            OfferProductView(viewModel: .catalogSample)
                .previewLayout(.fixed(width: 400, height: 800))
            
            OfferProductView(viewModel: .depositSample)
                .previewLayout(.fixed(width: 400, height: 800))
        }
    }
}

//MARK: - Preview Content

extension OfferProductView.ViewModel {
    
    static let catalogSample: OfferProductView.ViewModel = .init(with: .init(name: "Карта «Миг»", description: ["Получите карту с кешбэком в любом офисе без предварительного заказа!"], imageEndpoint: "", infoURL: URL(string: "https://www.forabank.ru/private/cards/")!, orderURL: URL(string: "https://www.forabank.ru/private/cards/")!))
    
    static let depositSample: OfferProductView.ViewModel = .init(with: .init(depositProductID: 10000003006, detailedСonditions: [.init(desc: "Капитализация процентов ко вкладу", enable: true)], documentsList: [.init(name: "string", url: URL(string: "https://www.forabank.ru/private/cards/")!)], generalСondition: .init(design: .init(background: [ColorData.init(description: "1C1C1C"), ColorData.init(description: "FFFFFF"), ColorData.init(description: "999999")], textColor: [ColorData.init(description: "1C1C1C"), ColorData.init(description: "FFFFFF"), ColorData.init(description: "999999")]), formula: "(initialAmount * interestRate * termDay/AllDay) / 100", generalTxtСondition: ["string"], imageLink: "urlImage", maxRate: 8.7, maxSum: 10000000, maxTerm: 731, maxTermTxt: "До 2-х лет", minSum: 5000, minSumCur: "RUB", minTerm: 31), name: "Сберегательный онлайн", termRateList: [.init(termRateSum: [.init(sum: 5000, termRateList: [.init(rate: 0.7, term: 31, termName: "1 месяц", termABS: 0, termKind: 0, termType: 0)])], сurrencyCode: "810", сurrencyCodeTxt: "RUB")], termRateCapList: [.init(termRateSum: [.init(sum: 5000, termRateList: [.init(rate: 0.7, term: 31, termName: "1 месяц", termABS: 0, termKind: 0, termType: 0)])], сurrencyCode: "810", сurrencyCodeTxt: "RUB")], txtСondition: ["string"]))
    
}

