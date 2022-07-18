//
//  ProductAccountViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductAccountView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var cardIcon: Image
        @Published var openAccountIcon: Image
        @Published var currencyType: String
        @Published var currencyName: String
        @Published var warning: WarningViewModel
        @Published var bottomSheet: BottomSheet?
        
        var bindings = Set<AnyCancellable>()
        
        let model: Model
        let title: String
        
        var currencyTitle: String {
            "Открыть \(currencyType) счет"
        }
        
        struct BottomSheet: Identifiable {
            
            let id = UUID()
            let type: SheetType
            
            enum SheetType {
                case openAccount(Model)
            }
        }
        
        init(model: Model,
             title: String = "Куда",
             cardIcon: Image,
             openAccountIcon: Image = Image("Plus Account"),
             currencyType: String,
             currencyName: String,
             warning: WarningViewModel) {
            
            self.model = model
            self.title = title
            self.cardIcon = cardIcon
            self.openAccountIcon = openAccountIcon
            self.currencyType = currencyType
            self.currencyName = currencyName
            self.warning = warning
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductAccountView.ProductAction.Toggle:
                        bottomSheet = .init(type: .openAccount(model))
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension ProductAccountView.ViewModel {
    
    // MARK: - Warning
    
    class WarningViewModel: ObservableObject {
        
        let icon: Image
        let description: String
        
        init(icon: Image = Image("Warning Account"), description: String) {
            
            self.icon = icon
            self.description = description
        }
    }
}

// MARK: - View

struct ProductAccountView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            ProductView(viewModel: viewModel)
            WarningView(viewModel: viewModel.warning)
        }
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
            switch bottomSheet.type {
            case let .openAccount(model):
                
                if let productsList = model.accountProductsList.value {

                    let viewModel: OpenAccountViewModel = .init(
                        model: model,
                        items: OpenAccountViewModel.reduce(products: productsList))

                    OpenAccountView(viewModel: viewModel)
                }
            }
        }
        .background(Color.mainColorsGrayLightest)
        .padding(.horizontal, 20)
    }
}

extension ProductAccountView {
    
    // MARK: - ProductView
    
    struct ProductView: View {
        
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
                            
                            Text(viewModel.currencyTitle)
                                .font(.textBodyMM14200())
                                .foregroundColor(.mainColorsBlack)
                            
                            Spacer()
                            
                            viewModel.openAccountIcon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        Text(viewModel.currencyName)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                    }
                }.onTapGesture {
                    
                    viewModel.action.send(ProductAccountView.ProductAction.Toggle())
                }
            }
        }
    }
    
    // MARK: - Warning
    
    struct WarningView: View {
        
        @ObservedObject var viewModel: ViewModel.WarningViewModel
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                
                Text(viewModel.description)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

extension ProductAccountView {
    
    enum ProductAction {
    
        struct Toggle: Action {}
    }
}

// MARK: - Preview Content

extension ProductAccountView.ViewModel {
    
    static let sample = ProductAccountView.ViewModel(
        model: .productsMock,
        cardIcon: Image("USD Account"),
        currencyType: "USD",
        currencyName: "Валютный",
        warning: .init(description: "Для завершения операции Вам необходимо открыть счет в долларах США"))
}

// MARK: - Previews

struct ProductAccountViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            ProductAccountView(viewModel: .sample)
                .padding()
        }
        .background(Color.mainColorsGrayLightest)
        .previewLayout(.sizeThatFits)
    }
}
