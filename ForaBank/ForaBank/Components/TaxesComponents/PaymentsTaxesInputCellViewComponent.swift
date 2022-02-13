//
//  PaymentsTaxesInputCellViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI
import Combine

extension PaymentsTaxesInputCellView {
    
    class ViewModel: ObservableObject {
        
        @Published var content: String = ""
        let logo: Image
        let title: String
        let placeholder: String
        private var bindings = Set<AnyCancellable>()
        let action: (String) -> Void
        
        func bind() {
            $content
                .receive(on: DispatchQueue.main)
                .sink { content in
                    self.content = content
                }.store(in: &bindings)
        }
        
        internal init(logo: Image, title: String, placeholder: String, action: @escaping (String) -> Void) {
            self.logo = logo
            self.title = title
            self.placeholder = placeholder
            self.action = action
            self.bind()
        }
        
    }
}

struct PaymentsTaxesInputCellView: View {
    
    @ObservedObject var viewModel: PaymentsTaxesInputCellView.ViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            
            viewModel.logo
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 10)  {
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#999999"))
                
                TextField(
                    viewModel.placeholder,
                    text: $viewModel.content,
                    onEditingChanged: { isChanged in

                        if isChanged {
                            viewModel.action(viewModel.content)
                        }
                    }
                )
                    .foregroundColor(Color(hex: "#1C1C1C"))
                    .font(Font.custom("Inter-Medium", size: 14))
                
                Divider()
                    .frame(height: 1)
                    .background(Color(hex: "#EAEBEB"))
                
            } .textFieldStyle(DefaultTextFieldStyle())
        }
    }
}


struct PaymentsTaxesInputCellViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsTaxesInputCellView(viewModel: .init(logo: Image("fora_white_back_bordered"),title: "Title", placeholder: "gh", action:{_ in }))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}


