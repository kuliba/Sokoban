//
//  ProfileCardViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 24.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProfileCardViewComponent {
    
    class ViewModel: ObservableObject {
        
        @Published var products: [ProductView.ViewModel]
        @State var product: ProductView.ViewModel
        @Published var moreButton: Bool
        
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init( products: [ProductView.ViewModel] = [], product: ProductView.ViewModel, moreButton: Bool, model: Model = .emptyMock) {
            
            self.products = products
            self.moreButton = moreButton
            self.product = product
            self.model = model
            
            bind()
            
        }
        
        init(_ model: Model) {
            
            self.products = []
            self.product = .init(with: .init(id: 0, productType: .card, number: "", numberMasked: "", accountNumber: "", balance: 1, balanceRub: nil, currency: "", mainField: "", additionalField: nil, customName: "", productName: "", openDate: Date(), ownerId: 0, branchId: 0, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [.init(description: "")]), statusAction: {}, action: {})
            self.moreButton = false
            self.model = model
            
            bind()
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

extension ProfileCardViewComponent {
    
    struct MiniCardViewModel {
        
        let background: Image?
        let product: ProductView.ViewModel
        let action: (ProductView.ViewModel) -> Void
    }
}

struct ProfileCardViewComponent: View {
    
    @ObservedObject var viewModel: ProfileCardViewComponent.ViewModel
    
    public var TabBar: some View {
        
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
                
                VStack(spacing: 15) {
                    if #available(iOS 14.0, *) {
                        
                        TabBar
                        
                        TabView(selection: $viewModel.product) {
                            
                            ForEach(viewModel.products) { product in
                                
                                if product.productType == .deposit {
                                    
                                    ProductView(viewModel: product)
                                        .frame(width: 228, height: 160)
                                        .tag(product)
                                    
                                } else {
                                    
                                    ProductView(viewModel: product)
                                        .frame(width: 268, height: 160, alignment: .top)
                                        .tag(product)
                                    
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame( height: 160, alignment: .top)
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
    
}

extension ProfileCardViewComponent {
    
    struct MiniCardView: View {
        
        let viewModel: ProfileCardViewComponent.MiniCardViewModel
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
                                .frame(width: 32, height: 24, alignment: .center)
                                .cornerRadius(3)
                            
                        } else {
                            
                            viewModel.product.appearance.background.color
                                .frame(width: 32, height: 24, alignment: .center)
                                .cornerRadius(3)
                        }
                    }
                    .frame(width: 32, height: 32, alignment: .center)
                    .padding(.all, 14)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(90)
                    
                } else {
                    
                    HStack(spacing: 6) {
                        
                        if let backgroundImage = viewModel.product.appearance.background.image {
                            
                            backgroundImage
                                .resizable()
                                .frame(width: 32, height: 24, alignment: .center)
                                .cornerRadius(3)                              .opacity(0.3)
                            
                            
                        } else {
                            
                            viewModel.product.appearance.background.color
                                .frame(width: 32, height: 24, alignment: .center)
                                .cornerRadius(3)
                                .opacity(0.3)
                            
                        }
                    }
                    .padding(.all, 14)
                }
            }
        }
    }
}

struct ProfileCardViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCardViewComponent(viewModel: .init(products: [.blockedProfile, .classicProfile, .accountProfile, .notActivateProfile, .accountSmall], product: .classicProfile, moreButton: true))
            .previewLayout(.fixed(width: 400, height: 500))
            .background(Color.orange)
    }
}
