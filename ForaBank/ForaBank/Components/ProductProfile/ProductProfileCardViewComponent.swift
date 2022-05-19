//
//  ProductProfileCardView.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileCardView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var products: [ProductView.ViewModel]
        @Published var product: ProductView.ViewModel
        @Published var moreButton: Bool = false
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init( products: [ProductView.ViewModel] = [], product: ProductView.ViewModel, model: Model) {
            
            
            self.products = products.filter({$0.productType == product.productType})
            self.product = product
            self.model = model
            
        }
        
        init(_ model: Model, productId: ProductData.ID, productType: ProductType) {
            
            self.products = []
            self.model = model

            let products = model.products.value.values.flatMap{ $0 }
            let productData = products.first(where: ({$0.id == productId}))
    
            if let balance = productData?.viewBalance, let fontColor = productData?.fontDesignColor.color, let name = productData?.viewName, let backgroundColor = productData?.background.first?.color {
                
                self.product = .init(header: .init(logo: nil, number: productData?.viewNumber, period: nil), name: name, footer: .init(balance: balance, paymentSystem: nil), statusAction: .init(status: .activation, style: .profile, action: {}), appearance: .init(textColor: fontColor, background: .init(color: backgroundColor, image: nil), size: .normal), isUpdating: false, productType: .init(rawValue: productData?.productType.rawValue ?? "card") ?? .card, action: {})
                
            } else {
                
                self.product = .init(header: .init(logo: nil, number: productData?.number, period: nil), name: productData?.mainField ?? "", footer: .init(balance: productData?.viewBalance ?? "", paymentSystem: nil), statusAction: nil, appearance: .init(textColor: productData?.fontDesignColor.color ?? .init(""), background: .init(color: productData?.background.first?.color ?? .init(""), image: productData?.extraLargeDesign.image!), size: .normal), isUpdating: true, productType: ProductType(rawValue: productData?.productType.rawValue ?? "CARD") ?? .card, action: {})
            }
            
            self.moreButton = false
            
            bind()
            
            action.send(ModelAction.Products.Update.Total.All())
            action.send(ModelAction.Products.Update.Fast.Single.Request(productId: product.id, productType: productType))
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] products in
                    
                    var items = [ProductView.ViewModel]()
                    
                    if let prodictTypeList = products[self.product.productType] {
                        
                        for productType in prodictTypeList {
                            
                            items.append(.init(with: productType, statusAction: {}, action: {}))
                            
                        }
                    }
                    
                    self.products = items
                    
                }.store(in: &bindings)
        }
    }
}

extension ProductProfileCardView {
    
    struct MiniCardViewModel {
        
        let background: Image?
        let product: ProductView.ViewModel
        let action: (ProductView.ViewModel) -> Void
    }
}

struct ProductProfileCardView: View {
    
    @ObservedObject var viewModel: ProductProfileCardView.ViewModel
    
    private var TabBar: some View {
        
        HStack(alignment: .center, spacing: 8) {
            
            ForEach(viewModel.products) { product in
                
                if let backgroundImage = product.appearance.background.image {
                    
                    MiniCardView(viewModel: MiniCardViewModel( background: backgroundImage, product: product, action: { productItem in
                        viewModel.product = productItem
                    }), isSelected: viewModel.product.id == product.id)
                    
                    
                } else {
                    
                    MiniCardView(viewModel: MiniCardViewModel( background: nil, product: product, action: { productItem in
                        viewModel.product = productItem
                    }), isSelected: viewModel.product.id == product.id)
                }
            }
            
            if viewModel.moreButton {
                
                Button {
                    
                } label: {
                    
                    Image.ic16MoreHorizontal
                        .foregroundColor(.black)
                }
                .frame(width: 32, height: 22, alignment: .center)
                .background(Color.white)
                .cornerRadius(3.0)
            }
        }
    }
    
    var body: some View {
        
        VStack {
            
            ZStack(alignment: .top) {
                
//                GeometryReader { geometry in
//
//                    ZStack {
//
//                        viewModel.product.appearance.background.color.contrast(0.8)
//                            .clipped()
//                    }
//                    .frame(height: 1200, alignment: .top)
////                    .offset(y: -(UIScreen.main.bounds.height-90))
//                }
                viewModel.product.appearance.background.color.contrast(0.8)
                    .frame(height: 155, alignment: .top)
                VStack(spacing: 0) {
                    
                    if #available(iOS 14.0, *) {
                        
                        TabBar
                            .frame(alignment: .bottom)
                        
                        TabView(selection: $viewModel.product) {
                            
                            ForEach(viewModel.products) { product in
                                
                                if product.productType == .deposit {
                                    
                                    ProductView(viewModel: product)
                                        .frame(width: 228, height: 160)
                                        .padding(.bottom, 20)
                                        .shadow(color: Color.mainColorsBlack.opacity(0.2), radius: 12, x: 0, y: 12)
                                        .tag(product)
                                    
                                } else {
                                    
                                    ProductView(viewModel: product)
                                        .frame(width: 268, height: 160)
                                        .padding(.bottom, 20)
                                        .shadow(color: Color.mainColorsBlack.opacity(0.2), radius: 12, x: 0, y: 12)
                                        .tag(product)
                                    
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 200, alignment: .top)
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
}

extension ProductProfileCardView {
    
    struct MiniCardView: View {
        
        let viewModel: ProductProfileCardView.MiniCardViewModel
        let isSelected: Bool
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.product)
                
            } label: {
                
                if isSelected {
                    
                    HStack(spacing: 6) {
                        
                        if let backgroundImage = viewModel.product.appearance.background.image {
                            
                            backgroundImage
                                .resizable()
                                .frame(width: 32, height: 22, alignment: .center)
                                .cornerRadius(3)
                            
                        } else {
                            
                            viewModel.product.appearance.background.color
                                .frame(width: 32, height: 22, alignment: .center)
                                .cornerRadius(3)
                        }
                    }
                    .frame(width: 32, height: 32, alignment: .center)
                    .padding(.all, 12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(90)
                    
                } else {
                    
                    HStack(spacing: 6) {
                        
                        if let backgroundImage = viewModel.product.appearance.background.image {
                            
                            backgroundImage
                                .resizable()
                                .frame(width: 32, height: 22, alignment: .center)
                                .cornerRadius(3).opacity(0.3)
                            
                            
                        } else {
                            
                            viewModel.product.appearance.background.color
                                .frame(width: 32, height: 22, alignment: .center)
                                .cornerRadius(3)
                                .opacity(0.3)
                            
                        }
                    }
                    .padding(.all, 12)
                }
            }
        }
    }
}

struct ProfileCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductProfileCardView(viewModel: .init(products: [.notActivateProfile, .classicProfile, .accountProfile, .blockedProfile, .depositProfile], product: .notActivateProfile, model: .emptyMock))
            .previewLayout(.fixed(width: 400, height: 500))
    }
}
