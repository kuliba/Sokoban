//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductSelectorView {

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var cardIcon: Image
        @Published var paymentSystemIcon: Image?
        @Published var name: String
        @Published var balance: String
        @Published var number: NumberViewModel
        
        @Published var listViewModel: ProductsListView.ViewModel?
        
        var bindings = Set<AnyCancellable>()
        
        let title: String
        let isDividerHiddable: Bool
        
        init(title: String,
             cardIcon: Image,
             paymentSystemIcon: Image?,
             name: String,
             balance: String,
             number: NumberViewModel,
             listViewModel: ProductsListView.ViewModel? = nil,
             isDividerHiddable: Bool = false) {
            
            self.title = title
            self.cardIcon = cardIcon
            self.paymentSystemIcon = paymentSystemIcon
            self.name = name
            self.balance = balance
            self.number = number
            self.listViewModel = listViewModel
            self.isDividerHiddable = isDividerHiddable
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as ProductSelectorView.ProductAction.Toggle:
                        
                        withAnimation(.easeOut) {
                            
                            switch listViewModel == nil {
                            case true: listViewModel = .sample
                            case false: listViewModel = nil
                            }
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    // MARK: - NumberCard
    
    class NumberViewModel: ObservableObject {
        
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

struct ProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            ProductView(viewModel: viewModel)
            
            if let listViewModel = viewModel.listViewModel {
                
                Divider()
                    .padding(.top, 2)
                    .padding(.horizontal, 20)
                
                ProductsListView(viewModel: listViewModel)
                    .padding(.top, 8)
                
            } else {
                
                if viewModel.isDividerHiddable == false {
                    
                    Divider()
                        .padding(.top, 2)
                        .padding(.horizontal, 20)
                }
            }
        }.background(Color.mainColorsGrayLightest)
    }
}

extension ProductSelectorView {
    
    enum ProductAction {
    
        struct Toggle: Action {}
    }
    
    // MARK: - ProductView
    
    struct ProductView : View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
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
                            
                            viewModel.paymentSystemIcon
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
                                .rotationEffect(viewModel.listViewModel == nil ? .degrees(0) : .degrees(-90))
                        }
                        
                        HStack {
                            ProductSelectorView.NumberCardView(viewModel: viewModel.number)
                        }
                    }
                }.onTapGesture {
                    
                    viewModel.action.send(ProductSelectorView.ProductAction.Toggle())
                }
            }.padding(.horizontal, 20)
        }
    }
    
    // MARK: - NumberCard
    
    struct NumberCardView: View {
        
        @ObservedObject var viewModel: ViewModel.NumberViewModel
        
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

extension ProductSelectorView.ViewModel {
    
    static let sample1 = ProductSelectorView.ViewModel(
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        number: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        listViewModel: nil)
    
    static let sample2 = ProductSelectorView.ViewModel(
        title: "Откуда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: Image("Platinum Logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        number: .init(
            numberCard: "4444555566662953",
            description: "Все включено"),
        listViewModel: .sample)
    
    static let sample3 = ProductSelectorView.ViewModel(
        title: "Куда",
        cardIcon: Image("Platinum Card"),
        paymentSystemIcon: nil,
        name: "Текущий счет",
        balance: "0 $",
        number: .init(
            numberCard: "",
            description: "Валютный"),
        isDividerHiddable: true)
}

// MARK: - Previews

struct ProductSelectorViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProductSelectorView(viewModel: .sample1)
                .previewLayout(.sizeThatFits)
                .padding()
            
            ProductSelectorView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
                .padding()
            
            ProductSelectorView(viewModel: .sample3)
                .previewLayout(.sizeThatFits)
                .padding()
            
        }.background(Color.mainColorsGrayLightest)
    }
}
