//
//  OptionSelectorViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 21.01.2022.
//

import SwiftUI

class OptionSelectorViewModel: ObservableObject {
    
    @Published var options: [OptionViewModel]
    @Published var selected: Option.ID
 
    internal init(options: [Option], selected: Option.ID) {
        self.options = []
        self.selected = selected
        self.options = options.map{ OptionViewModel(id: $0.id, title: $0.name, action: { [weak self] optionId in self?.selected = optionId })}
    }
}

extension OptionSelectorViewModel {
        
    struct OptionViewModel: Identifiable {
        let id: Option.ID
        let title: String
        let action: (OptionViewModel.ID) -> Void
    }
}

struct OptionSelectorView: View {
    
    @ObservedObject var viewModel: OptionSelectorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.options) { optionViewModel in
                    OptionButtonView(
                        viewModel: optionViewModel,
                        isSelected: viewModel.selected == optionViewModel.id
                    )
                }
            }
            .padding(.leading, 20)
        }
    }
}

extension OptionSelectorView {
    
    struct OptionButtonView: View {
        
        let viewModel: OptionSelectorViewModel.OptionViewModel
        let isSelected: Bool
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                if isSelected {
                    
                    Text(viewModel.title)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().foregroundColor(Color(hex: "#3D3D45")))
                } else {
                    
                    Text(viewModel.title)
                        .foregroundColor(Color(hex: "#3D3D45"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().foregroundColor(Color(hex: "#F6F6F7")))
                }
            }
            //TODO: add custom button style
        }
    }
}

struct OptionSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        OptionSelectorView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 40))
    }
}

extension OptionSelectorViewModel {
    static let sample = OptionSelectorViewModel(options: [
        .init(id: "all", name: "Все" ),
        .init(id: "add", name: "Пополнение"),
        .init(id: "addi", name: "Коммунальные"),
        .init(id: "addit", name: "Переводы"),
        .init(id: "additi", name: "Пополнение"),
        .init(id: "additio", name: "Пополнение")
    ], selected: "all")
    
}
