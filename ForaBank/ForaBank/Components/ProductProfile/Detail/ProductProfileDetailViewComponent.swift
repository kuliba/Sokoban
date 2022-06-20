//
//  ProductProfileAccountDetailViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 11.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileDetailView {
    
    class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()
        
        lazy var header: HeaderViewModel = .init(action: { [weak self] in self?.action.send(ProductProfileDetailViewModelAction.ToggleCollapsed())})
        @Published var info: InfoViewModel
        @Published var mainBlock: MainBlockViewModel
        @Published var footer: FooterViewModel?
        @Published var isCollapsed: Bool
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(info: InfoViewModel, mainBlock: MainBlockViewModel, footer: FooterViewModel?, isCollapsed: Bool) {
            
            self.info = info
            self.mainBlock = mainBlock
            self.footer = footer
            self.isCollapsed = isCollapsed
            
            bind()
        }
        
        init?(productCard: ProductCardData, model: Model) {
            
            // check if it credit card
            
            guard let loanData = productCard.loanBaseParam else {
                return nil
            }
            
            if productCard.isActivated == true {
                
                
            } else {
                
                // credit card is not activated yet
                
                self.info = .message("Поздравляем 🎉, Вы стали обладателем кредитной карты. Оплачивайте покупки и получайте Кешбэк и скидки от партнеров.")
                self.mainBlock = .init(loanData: loanData, model: model, action: {})
                self.isCollapsed = true
                
            }
            
            return nil
        }

        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductProfileDetailViewModelAction.ToggleCollapsed:
                        withAnimation {
                            
                            isCollapsed.toggle()
                        }
                        
                    /*
                    case _ as AntifraudViewModelAction.Cancel:
                        NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                     */
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        header.isCollapsed = isCollapsed
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Actions

enum ProductProfileDetailViewModelAction {

    struct ToggleCollapsed: Action {}
}

//MARK: - View
struct ProductProfileDetailView: View {
    
    @ObservedObject var viewModel: ProductProfileDetailView.ViewModel

    @available(iOS 14.0, *)
    @Namespace var namespace
    
    var body: some View {
        
        if #available(iOS 14, *) {
            
            VStack {
                
                ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                
                ProductProfileDetailView.InfoView(viewModel: viewModel.info)
                    .frame(height: 62)
                
                if viewModel.isCollapsed == false {
                    
                    ProductProfileDetailView.MainBlockView(viewModel: viewModel.mainBlock)
                        .matchedGeometryEffect(id: "main", in: namespace)
                        .frame(height: 112)
                    
                } else {
                    
                    Color.clear
                        .matchedGeometryEffect(id: "main", in: namespace)
                        .frame(height: 0.05)
                }
                
                if viewModel.isCollapsed == false {
                    
                    if let footerViewModel = viewModel.footer {
                        
                        ProductProfileDetailView.FooterView(viewModel: footerViewModel)
                            .matchedGeometryEffect(id: "footer", in: namespace)
                    }
                    
                } else {
                    
                    Color.clear
                        .matchedGeometryEffect(id: "footer", in: namespace)
                        .frame(height: 0.05)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 18)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsBlack))
            
        } else {
            
            VStack {
                
                if viewModel.isCollapsed == true {
                    
                    ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                    ProductProfileDetailView.InfoView(viewModel: viewModel.info)
                        .frame(height: 62)
                    
                } else {
                    
                    ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                    ProductProfileDetailView.InfoView(viewModel: viewModel.info)
                        .frame(height: 62)
                    
                    ProductProfileDetailView.MainBlockView(viewModel: viewModel.mainBlock)
                        .frame(height: 112)
                    
                    if let footerViewModel = viewModel.footer {
                        
                        ProductProfileDetailView.FooterView(viewModel: footerViewModel)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 18)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsBlack))
        }
    }
}



//MARK: - Preview

struct ProductProfileDetailView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {
            
            ProductProfileDetailView(viewModel: .sampleCollapsed)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 180))
            
            ProductProfileDetailView(viewModel: .sampleMessage)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 300))
            
            ProductProfileDetailView(viewModel: .sample)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 420))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel {
    
    static let sampleCollapsed = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: true)
    
    static let sample = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: false)
    
    static let sampleMessage = ProductProfileDetailView.ViewModel(info: .sampleMessage, mainBlock: .sampleCredit, footer: nil, isCollapsed: false)
}
