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
        
        let title: String
        
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
             state: State) {
            
            self.title = title
            self.cardIcon = cardIcon
            self.logoIcon = logoIcon
            self.name = name
            self.balance = balance
            self.numberCard = numberCard
            self.state = state
        }
    }
}

extension ProductCardView.ViewModel {
    
    enum State {
        
        case normal
        case expanded(ProductsListView.ViewModel)
    }
    
    // MARK: - NumberCard
    
    class NumberCardViewModel: ObservableObject {
        
        let title: String
        let description: String
        
        var numberLastTitle: String {
            "\(title.suffix(4))"
        }
        
        init(title: String, description: String) {
            
            self.title = title
            self.description = description
        }
    }
}

// MARK: - View

struct ProductCardView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .padding(.leading, 48)
            
            HStack(alignment: .top, spacing: 16) {
               
                viewModel.cardIcon
                    .resizable()
                    .frame(width: 32, height: 32)
                
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
            }.onTapGesture {}
            
            switch viewModel.state {
            case .normal:
                EmptyView()
                
            case .expanded(let model):
                
                ProductsListView(viewModel: model)
                    .padding(.top, 8)
            }
        }
    }
}

extension ProductCardView {
    
    // MARK: - NumberCard
    
    struct NumberCardView: View {
        
        @ObservedObject var viewModel: ViewModel.NumberCardViewModel
        
        var body: some View {
            
            HStack {
                
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.numberLastTitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
                
                Circle()
                    .frame(width: 2, height: 2)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.description)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

// MARK: - Preview Content

extension ProductCardView.ViewModel {
    
    static let sample = ProductCardView.ViewModel(
        title: "Откуда",
        cardIcon: Image("Platinume Card"),
        logoIcon: Image("card_mastercard_logo"),
        name: "Platinum",
        balance: "2,71 млн ₽",
        numberCard: .init(
            title: "4444555566662953",
            description: "Все включено"),
        state: .normal)
}

// MARK: - Previews

struct ProductCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(viewModel: .sample)
            .frame(height: 70)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
