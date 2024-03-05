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
        
        TopView(viewModel: .init(initialState: .init(products: [])))
            .frame(maxHeight: .infinity)
        
        BottomView()
            .frame(maxHeight: .infinity)
    }
}

struct TopView: View {
    
    @StateObject var viewModel: CarouselViewModel
    @State private var selectedProduct: Product?
    @State private var isShowing = true
    
    var body: some View {
                    
        VStack {
            
            Toggle(isOn: $isShowing) {
                
                Text("Show/hide")
            }
            
            Button("Update products") {
                
                viewModel.event(.update(.cards))
            }
            
            Button("Add more products") {
                
                viewModel.event(.update(.cards + .moreProducts))
            }
            .padding()
            
            if isShowing {
                
                CarouselWrapperView(viewModel: viewModel) { product in
                    
                    ProductView(product: product)
                        .onTapGesture { selectedProduct = product }
                }
            }
        }
        .sheet(item: $selectedProduct) {
            
            $0.color
                .frame(width: 200, height: 200)
        }
    }
}

struct BottomView: View {
    
    @State private var product: Product = .card
    @State private var isShowing = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                product.color
                    .frame(width: 100, height: 32)
                    .overlay { Text("\(product.id.value.rawValue)") }
                
                Spacer()
                
                Button("Show products") {
                    
                    isShowing.toggle()
                }
            }
            .padding()
            
            if isShowing {
                
                CarouselStateWrapperView(products: .cards) { product in
                    
                    ProductView(product: product)
                        .onTapGesture {
                            
                            self.product = product
                            isShowing = false
                        }
                }
            }
        }
    }
}

struct ProductView: View {
    
    let product: Product
        
    var body: some View {
        
        product.color
            .cornerRadius(10)
            .frame(width: 121, height: 70)
            .overlay { Text("\(product.id.value.rawValue)") }
    }
}
