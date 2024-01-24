//
//  ContentView.swift
//  DecimalTextFieldPreview
//
//  Created by Igor Malyarov on 15.12.2023.
//

import SberQR
import SwiftUI
import TextFieldComponent

struct ContentView: View {
    
    @StateObject private var viewModel: DecimalTextFieldViewModel
    
    init() {
        
        self._viewModel = .init(wrappedValue: .decimal(
            formatter: .init(currencySymbol: "₽")
        ))
    }
    
    var body: some View {
        
        VStack {
            
            Text("Decimal Text Field")
                .font(.title.bold())
            
            TextFieldView(
                viewModel: viewModel,
                textFieldConfig: .init(
                    font: .boldSystemFont(ofSize: 32),
                    textColor: .green,
                    tintColor: .accentColor,
                    backgroundColor: .clear,
                    placeholderColor: .clear
                )
            )
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
