//
//  SwiftUIView.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

struct ContentView : View {
    
    @ObservedObject var viewModel: PinCodeViewModel
    @State private var string = "0"
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 52) {
            
            PinCodeView(
                viewModel: viewModel,
                config: viewModel.config.pinCodeConfig)
            KeyPad(
                string: $string,
                config: viewModel.config.buttonConfig,
                deleteImage: Image(systemName: "delete.backward"),
                pinCodeLength: viewModel.pincodeLength,
                action: {
                    
                    print("надо сменить экран")
                }
            )
            .fixedSize()
        }
        .font(.largeTitle)
        .padding()
    }
}

struct ContentView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ContentView(
                viewModel:
                    .defaultValue
                )
        }
    }
}
