//
//  MainBlockProductSelector.swift
//  ForaBank
//
//  Created by Дмитрий on 21.02.2022.
//

import Foundation
import SwiftUI

class MainBlockProductSelectorViewModel: ObservableObject {
    
    @Published var options: [MainBlockProductViewModel]
    @Published var selected: Option.ID
 
    internal init(options: [Option], selected: Option.ID) {
        self.options = []
        self.selected = selected
        self.options = options.map{ MainBlockProductViewModel(id: $0.id, title: $0.name, action: { [weak self] optionId in self?.selected = optionId })}
    }
}

extension MainBlockProductSelectorViewModel {
        
    struct MainBlockProductViewModel: Identifiable {
        let id: Option.ID
        let title: String
        let action: (MainBlockProductViewModel.ID) -> Void
    }
}

struct MainBlockProductSelectorView: View {
    
    @ObservedObject var viewModel: MainBlockProductSelectorViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.options) { optionViewModel in
                    MainBlockProductButtonView(
                        viewModel: optionViewModel,
                        isSelected: viewModel.selected == optionViewModel.id
                    )
                }
            }
        }
        .padding(.leading, 20)
    }
}

extension MainBlockProductSelectorView {
    
    struct MainBlockProductButtonView: View {
        
        let viewModel: MainBlockProductSelectorViewModel.MainBlockProductViewModel
        let isSelected: Bool
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                if isSelected {
                    
                    HStack(spacing: 6) {
                        
                        Circle()
                            .frame(width: 4, height: 4, alignment: .center)
                            .foregroundColor(.mainColorsRed)
                        
                        Text(viewModel.title)
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 6)
                    }
                } else {
                    
                    HStack(spacing: 6) {

                    Circle()
                        .frame(width: 4, height: 4, alignment: .center)
                        .foregroundColor(.mainColorsGrayLightest)
                        
                    Text(viewModel.title)
                            .foregroundColor(.mainColorsGray)
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.trailing, 12)
        }
    }
}

struct MainBlockProductSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MainBlockProductSelectorView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 40))
    }
}

extension MainBlockProductSelectorViewModel {
    static let sample = MainBlockProductSelectorViewModel(options: [
        .init(id: "all", name: "Карты" ),
        .init(id: "add", name: "Счета"),
        .init(id: "addi", name: "Вклады"),
        .init(id: "addit", name: "Кредиты"),
        .init(id: "additi", name: "Страховки"),
    ], selected: "all")
    
}
