//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductCardView {

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var cardIcon: Image
        @Published var logoIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var numberCard: NumberCardViewModel
        @Published var state: State
        
        var bindings = Set<AnyCancellable>()
        
        let title: String
        let isDividerHiddable: Bool
        
        var isExpanded: Bool {
            
            switch state {
            case .normal: return false
            case .expanded: return true
            }
        }
        
        init(title: String,
             cardIcon: Image,
             logoIcon: Image?,
             name: String,
             balance: String,
             numberCard: NumberCardViewModel,
             state: State,
             isDividerHiddable: Bool = false) {
            
            self.title = title
            self.cardIcon = cardIcon
            self.logoIcon = logoIcon
            self.name = name
            self.balance = balance
            self.numberCard = numberCard
            self.state = state
            self.isDividerHiddable = isDividerHiddable
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as ProductCardView.ProductAction.Toggle:
                        
                        withAnimation(.easeOut) {
                            
                            switch state {
                            case .normal:
                                state = .expanded(.sample)
                            case .expanded:
                                state = .normal
                            }
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        enum State {
            
            case normal
            case expanded(ProductsListView.ViewModel)
        }
    }
}

extension ProductCardView.ViewModel {
    
    // MARK: - NumberCard
    
    class NumberCardViewModel: ObservableObject {
        
        let numberCard: String
        let description: String
        
        var numberCardLast: String {
            "\(numberCard.suffix(4))"
        }
        
        init(numberCard: String, description: String) {
            
            self.numberCard = numberCard
            self.description = description
        }
    }
}

// MARK: - View

struct ProductCardView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Group {
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    viewModel.cardIcon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .offset(y: -3)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(alignment: .center, spacing: 10) {
                            
                            viewModel.logoIcon
                                .frame(width: 24, height: 24)
                            
                            Text(viewModel.name)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            Text(viewModel.balance)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Image.ic24ChevronDown
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.mainColorsGray)
                                .rotationEffect(viewModel.isExpanded ? .degrees(0) : .degrees(-90))
                        }
                        
                        HStack {
                            NumberCardView(viewModel: viewModel.numberCard)
                        }
                    }
                }.onTapGesture {
                    
                    viewModel.action.send(ProductAction.Toggle())
                }
            }.padding(.horizontal, 20)
            
            switch viewModel.state {
            case .normal:
                
                if viewModel.isDividerHiddable == false {
                    
                    Divider()
                        .padding(.top, 2)
                        .padding(.horizontal, 20)
                }
                
                EmptyView()
                
            case .expanded(let model):
                
                Divider()
                    .padding(.top, 2)
                    .padding(.horizontal, 20)
                
                ProductsListView(viewModel: model)
                    .padding(.top, 8)
            }
            
        }.background(Color.mainColorsGrayLightest)
    }
}

extension ProductCardView {
    
    enum ProductAction {
    
        struct Toggle: Action {}
    }
    
    // MARK: - NumberCard
    
    struct NumberCardView: View {
        
        @ObservedObject var viewModel: ViewModel.NumberCardViewModel
        
        var body: some View {
            
            HStack {
                
                if viewModel.numberCard.isEmpty == false {
                    
                    Circle()
                        .frame(width: 3, height: 3)
                        .foregroundColor(.mainColorsGray)
                    
                    Text(viewModel.numberCardLast)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                    
                    Circle()
                        .frame(width: 3, height: 3)
                        .foregroundColor(.mainColorsGray)
                }
                
                Text(viewModel.description)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

// MARK: - Preview Content

extension ProductCardView.ViewModel {
    
    static let sample1 = ProductCardView.ViewModel(
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        logoIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        state: .normal)
    
    static let sample2 = ProductCardView.ViewModel(
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        logoIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        state: .expanded(.sample))
    
    static let sample3 = ProductCardView.ViewModel(
        title: "Куда",
        cardIcon: Image("Platinum Card"),
        logoIcon: nil,
        name: "Текущий счет",
        balance: "0 $",
        numberCard: .init(
            numberCard: "",
            description: "Валютный"),
        state: .normal,
        isDividerHiddable: true)
}

// MARK: - Previews

struct ProductCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProductCardView(viewModel: .sample1)
                .previewLayout(.sizeThatFits)
                .padding()
            
            ProductCardView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
                .padding()
            
            ProductCardView(viewModel: .sample3)
                .previewLayout(.sizeThatFits)
                .padding()
            
        }.background(Color.mainColorsGrayLightest)
    }
}
