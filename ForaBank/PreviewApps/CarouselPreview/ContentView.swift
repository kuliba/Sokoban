//
//  ContentView.swift
//  CarouselPreview
//
//  Created by Igor Malyarov on 15.02.2024.
//

import RxViewModel
import SwiftUI
import CarouselComponent

struct ContentView: View {
        
    var body: some View {
    
        CarouselMainView(
            viewModel: .init(initialState: .init(products: .allProducts))) { product in
                
                switch product.id.type {
                case .account:
                    return ProductView(viewModel: .account)
                    
                case .card:
                    return ProductView(viewModel: .classic)
                    
                case .deposit:
                    return ProductView(viewModel: .depositProfile)
                    
                case .loan:
                    return ProductView(viewModel: .blocked)
                    
                }
            }
    }
}

struct CarouselMainView: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    
    init(
        viewModel: CarouselViewModel,
        productView: @escaping (Product) -> ProductView
    ) {
        self.viewModel = viewModel
        self.productView = productView
    }
    
    var body: some View {
        
        CarouselWrapperView(
            viewModel: viewModel,
            productView: productView
        )
    }
}

//struct ProductProfileView: View {
//    
//        
//    var body: some View {
//        
//        openCardGuardianButton()
//    }
//    
//    private func openCardGuardianButton() -> some View {
//        
//        Button(
//            "Управление",
//            action: viewModel.openCardGuardian
//        )
//        .buttonStyle(.bordered)
//        .controlSize(.large)
//        .alert(
//            item: .init(
//                get: { viewModel.state.alert },
//                set: { if $0 == nil { viewModel.event(.closeAlert) }}
//            ),
//            content: { .init(with: $0, event: viewModel.event) }
//        )
//        .sheet(
//            item: .init(
//                get: { viewModel.state.modal },
//                set: { if $0 == nil { viewModel.event(.dismissDestination) }}
//            ),
//            content: destinationView
//        )
//    }
//    
//    private func destinationView(
//        cgRoute: ProductProfileNavigation.State.ProductProfileRoute
//    ) -> some View {
//        
//        CardGuardianModule.ThreeButtonsWrappedView(
//            viewModel: cgRoute.viewModel,
//            config: .preview)
//        .padding(.top, 26)
//        .padding(.bottom, 72)
//        .presentationDetents([.height(300)])
//    }
//}
//
//#Preview {
//    ProductProfileView.cardBlockedHideOnMain
//}


//struct TopView: View {
//    
//    @StateObject var viewModel: CarouselViewModel
//    @State private var selectedProduct: Product?
//    @State private var isShowing = true
//    
//    var body: some View {
//                    
//        VStack {
//            
//            Toggle(isOn: $isShowing) {
//                
//                Text("Show/hide")
//            }
//            
//            Button("Update products") {
//                
//                viewModel.event(.update(.cards))
//            }
//            
//            Button("Add more products") {
//                
//                viewModel.event(.update(.cards + .moreProducts))
//            }
//            .padding()
//            
//            if isShowing {
//                
//                CarouselWrapperView(viewModel: viewModel) { product in
//                    
//                    ProductView(product: product)
//                        .onTapGesture { selectedProduct = product }
//                }
//            }
//        }
//        .sheet(item: $selectedProduct) {
//            
//            $0.color
//                .frame(width: 200, height: 200)
//        }
//    }
//}

//struct BottomView: View {
//    
//    @State private var product: Product = .card
//    @State private var isShowing = false
//    
//    var body: some View {
//        
//        VStack {
//            
//            HStack {
//                
//                product.color
//                    .frame(width: 100, height: 32)
//                    .overlay { Text("\(product.id.value.rawValue)") }
//                
//                Spacer()
//                
//                Button("Show products") {
//                    
//                    isShowing.toggle()
//                }
//            }
//            .padding()
//            
//            if isShowing {
//                
//                CarouselStateWrapperView(products: .cards) { product in
//                    
//                    ProductView(product: product)
//                        .onTapGesture {
//                            
//                            self.product = product
//                            isShowing = false
//                        }
//                }
//            }
//        }
//    }
//}
//
//struct ProductView: View {
//    
//    let product: Product
//        
//    var body: some View {
//        
//        product.color
//            .cornerRadius(10)
//            .frame(width: 121, height: 70)
//            .overlay { Text("\(product.id.value.rawValue)") }
//    }
//}
