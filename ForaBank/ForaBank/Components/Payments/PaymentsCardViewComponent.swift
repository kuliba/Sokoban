//
//  PaymentsCardViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsCardView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let title: String
        @Published var cardIcon: Image
        @Published var paymentSystemIcon: Image?
        @Published var name: String
        @Published var amount: String
        @Published var captionItems: [CaptionItemViewModel]
        
        @Published var state: State
        
        var isExpanded: Bool {
            
            switch state {
            case .normal: return false
            case .expanded: return true
            }
        }
        
        private var bindings = Set<AnyCancellable>()
        private var selectorBinding: AnyCancellable?
        
        static let cardIconPlaceholder = Image("Placeholder Card Small")
        
        init(title: String, cardIcon: Image, paymentSystemIcon: Image?, name: String, amount: String, captionItems: [CaptionItemViewModel], state: State, parameterCard: Payments.ParameterCard = .init()) {
            
            self.title = title
            self.cardIcon = cardIcon
            self.paymentSystemIcon = paymentSystemIcon
            self.name = name
            self.amount = amount
            self.captionItems = captionItems
            self.state = state
            
            super.init(source: parameterCard)
            bind()
        }

        init(with parameterCard: Payments.ParameterCard) {
            
            self.title = "Счет списания"
            self.cardIcon = Self.cardIconPlaceholder
            self.paymentSystemIcon = Image("card_mastercard_logo")
            self.name = "Основная"
            self.amount = "170 897 ₽"
            self.captionItems = [.init(title: "4996"), .init(title: "Корпоротивная")]
            self.state = .normal
            
            super.init(source: parameterCard)
            bind()
        }
        
        func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case _ as PaymentsCardView.ViewModelAction.ToggleSelector:
                        
                        withAnimation {
                            
                            switch state {
                            case .normal:
                                
                                let selectorViewModel = PaymentsProductSelectorView.ViewModel(.emptyMock)
                                state = .expanded(selectorViewModel)
                                bind(selector: selectorViewModel)
                                
                            case .expanded:
                                state = .normal
                            }
                        }

                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        func bind(selector: PaymentsProductSelectorView.ViewModel) {

            selectorBinding = selector.action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsProductSelectorView.ViewModelAction.SelectedProduct:
                        //TODO: update product with id
                        withAnimation {
                            
                            state = .normal
                        }
                    
                    default:
                        break
                    }
                }
        }
        
        enum State {
            
            case normal
            case expanded(PaymentsProductSelectorView.ViewModel)
        }
        
        struct CaptionItemViewModel: Identifiable {
            
            let id = UUID()
            let title: String
        }
    }
    
    enum ViewModelAction {
    
        struct ToggleSelector: Action {}
    }
}

//MARK: - View

struct PaymentsCardView: View {
    
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
                        
                        viewModel.paymentSystemIcon
                            .frame(width: 24, height: 24)
                        
                        Text(viewModel.name)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(viewModel.amount)
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
                      
                        ForEach(viewModel.captionItems) { itemViewModel in
                            
                            PaymentsCardView.CaptionItemView(viewModel: itemViewModel)
                        }
                    }
                }
            }
            .onTapGesture {
                
                viewModel.action.send(PaymentsCardView.ViewModelAction.ToggleSelector())
            }
            
            switch viewModel.state {
            case .normal:
                EmptyView()
                
            case .expanded(let productSelectorViewModel):
                PaymentsProductSelectorView(viewModel: productSelectorViewModel)
                    .padding(.top, 8)
            }
        }
    }
}

extension PaymentsCardView {
    
    struct CaptionItemView: View {
        
        let viewModel: ViewModel.CaptionItemViewModel
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                Circle()
                    .frame(width: 2, height: 2)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
            }
        }
    }
}

//MARK: - Preview

struct PaymentsCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsCardView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 90))
            
            PaymentsCardView(viewModel: .sampleExpanded)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsCardView.ViewModel {
    
    static let sample = PaymentsCardView.ViewModel(title: "Счет списания", cardIcon: cardIconPlaceholder, paymentSystemIcon: Image("card_mastercard_logo"), name: "Основная", amount: "170 897 ₽", captionItems: [.init(title: "4996"), .init(title: "Корпоротивная")], state: .normal)
    
    static let sampleExpanded = PaymentsCardView.ViewModel(title: "Счет списания", cardIcon: cardIconPlaceholder, paymentSystemIcon: Image("card_mastercard_logo"), name: "Основная", amount: "170 897 ₽", captionItems: [.init(title: "4996"), .init(title: "Корпоротивная")], state: .expanded(.sample))
}



