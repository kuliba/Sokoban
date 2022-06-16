//
//  OptionSelectorViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 21.01.2022.
//

import SwiftUI

//MARK: - View Model

extension OptionSelectorView {
    
    class ViewModel: ObservableObject {
        
        @Published var options: [OptionViewModel]
        @Published var selected: Option.ID
        let style: Style
        let horizontalPadding: CGFloat
     
        internal init(options: [Option], selected: Option.ID, style: Style, horizontalPadding: CGFloat = 0) {
           
            self.options = []
            self.selected = selected
            self.style = style
            self.horizontalPadding = horizontalPadding
            
            self.options = options.map{ OptionViewModel(id: $0.id, title: $0.name, style: style, action: { [weak self] optionId in self?.selected = optionId })}
        }
        
        enum Style {
            
            case template
            case products
            case productsSmall
        }
        
        struct OptionViewModel: Identifiable {
            
            let id: Option.ID
            let title: String
            let style: Style
            let action: (OptionViewModel.ID) -> Void
        }
    }
}


//MARK: - View

struct OptionSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var spacing: CGFloat {
        
        switch viewModel.style {
        case .template: return 8
        case .products: return 12
        case .productsSmall: return 12
        }
    }
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: spacing) {
                
                ForEach(viewModel.options) { optionViewModel in
                    
                    OptionButtonView(viewModel: optionViewModel, isSelected: viewModel.selected == optionViewModel.id)
                }
                
            }.padding(.horizontal, 20)
        }
    }
}

//MARK: - Subviews

extension OptionSelectorView {
    
    struct OptionButtonView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let isSelected: Bool
        
        var body: some View {
            
            switch viewModel.style {
            case .template:
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
                
            case .products:
                Button {
                    
                    viewModel.action(viewModel.id)
                    
                } label: {
                    
                    if isSelected {
                        
                        HStack(spacing: 4) {
                            
                            Circle()
                                .frame(width: 4, height: 4, alignment: .center)
                                .foregroundColor(.mainColorsRed)
                            
                            Text(viewModel.title)
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 6)
                        }
                        
                    } else {
                        
                        HStack(spacing: 4) {

                        Circle()
                            .frame(width: 4, height: 4, alignment: .center)
                            .foregroundColor(.mainColorsGrayLightest)
                            
                        Text(viewModel.title)
                                .foregroundColor(.mainColorsGray)
                            .padding(.vertical, 6)
                        }
                    }
                }
                
            case .productsSmall:
                Button {
                    
                    viewModel.action(viewModel.id)
                    
                } label: {
                    
                    if isSelected {
                        
                        HStack(spacing: 4) {
                            
                            Circle()
                                .frame(width: 4, height: 4, alignment: .center)
                                .foregroundColor(.mainColorsRed)
                            
                            Text(viewModel.title)
                                .font(.textBodySM12160())
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 6)
                        }
                        
                    } else {
                        
                        HStack(spacing: 4) {

                        Circle()
                            .frame(width: 4, height: 4, alignment: .center)
                            .foregroundColor(.mainColorsGrayLightest)
                            
                        Text(viewModel.title)
                                .font(.textBodySM12160())
                                .foregroundColor(.textPlaceholder)
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct OptionSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            OptionSelectorView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 40))
            
            OptionSelectorView(viewModel: .mainSample)
                .previewLayout(.fixed(width: 375, height: 40))
        }
    }
}

//MARK: - Preview Content

extension OptionSelectorView.ViewModel {
    
    static let sample = OptionSelectorView.ViewModel(options: [
        .init(id: "all", name: "Все" ),
        .init(id: "add", name: "Пополнение"),
        .init(id: "addi", name: "Коммунальные"),
        .init(id: "addit", name: "Переводы"),
        .init(id: "additi", name: "Пополнение"),
        .init(id: "additio", name: "Пополнение")
    ], selected: "all", style: .template)
    
    static let mainSample = OptionSelectorView.ViewModel(options: [
        .init(id: "all", name: "Карты" ),
        .init(id: "add", name: "Счета"),
        .init(id: "addi", name: "Вклады"),
        .init(id: "addit", name: "Кредиты"),
        .init(id: "additi", name: "Страховка")
    ], selected: "all", style: .products)
    
}
