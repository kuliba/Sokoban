//
//  PaymentsParameterAdditionalButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterAdditionalButtonView {
    
    class ViewModel: ObservableObject {
        
        let title: String
        @Published var isSelected: Bool
        @Published var icon: Image
        private var bindings = Set<AnyCancellable>()
        
        internal init(title: String, isSelected: Bool) {
            self.title = title
            self.isSelected = isSelected
            self.icon = Self.icon(isSelected: isSelected)
            self.bind()
        }
        
        static func icon( isSelected: Bool) -> Image {
            
            switch isSelected {
            case true:
                return Image("Vector_1")
            case false:
                return Image("Vector")
                
            }
        }
        
        func bind() {
            $isSelected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isSelected in
                    self.icon = Self.icon(isSelected: isSelected)
                }.store(in: &bindings)
        }
        
    }
}

//MARK: - View

struct PaymentsParameterAdditionalButtonView: View {
    
    @ObservedObject var viewModel: PaymentsParameterAdditionalButtonView.ViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                viewModel.isSelected.toggle()
            } label: {
                viewModel.icon
                    .padding()
                Text(viewModel.title)
                    .padding()
                    .foregroundColor(Color(hex: "#1C1C1C"))
            }
        } .background(Color(hex: "#F6F6F7"))
            .cornerRadius(8)
    }
}

//MARK: - Preview

struct PaymentsParameterAdditionalButtonView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsParameterAdditionalButtonView(viewModel: .init(title: "Дополнительные данные", isSelected: false))
            .previewLayout(.fixed(width: 375, height: 40))
    }
}
