//
//  OptionSelectorViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 21.01.2022.
//

import SwiftUI
import Combine

//MARK: - View Model

extension OptionSelectorView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var options: [OptionViewModel]
        @Published var selected: Option.ID
        let style: Style
        let mode: Mode

        internal init(options: [Option], selected: Option.ID, style: Style, mode: Mode = .auto) {
            
            self.options = []
            self.selected = selected
            self.style = style
            self.mode = mode
            
            typealias OptionDidSelected = OptionSelectorAction.OptionDidSelected
            
            self.options = options.map {
                .init(
                    id: $0.id,
                    title: $0.name,
                    style: style,
                    action: { [weak self] optionId in
                        
                        guard let self = self else { return }
                        
                        switch self.mode {
                        case .auto:
                            self.selected = optionId
                            
                        case .action:
                            self.selected = optionId
                            self.action.send(OptionDidSelected(optionId: optionId))
                        }
                    }
                )
            }
        }
        
        func update(options: [Option], selected: Option.ID) {
            
            typealias OptionDidSelected = OptionSelectorAction.OptionDidSelected
            
            self.options = options.map {
                .init(
                    id: $0.id,
                    title: $0.name,
                    style: style,
                    action: { [weak self] optionId in
    
                        guard let self = self else { return }

                        self.selected = optionId
                        self.action.send(OptionDidSelected(optionId: optionId))
                        
                        /*
                         guard let self = self else { return }
                         
                         switch self.mode {
                         case .auto:
                             self.selected = optionId
                             
                         case .action:
                             self.selected = optionId
                             self.action.send(OptionDidSelected(optionId: optionId))
                         }
                         */
                    }
                )
            }
            self.selected = selected
        }
        
        enum Style {
            
            case template
            case products
            case productsSmall
        }
        
        enum Mode {
            
            case auto
            case action
        }
        
        struct OptionViewModel: Identifiable {
            
            let id: Option.ID
            let title: String
            let style: Style
            let action: (OptionViewModel.ID) -> Void
        }
    }
}

//MARK: - Action

enum OptionSelectorAction {
    
    struct OptionDidSelected: Action {
        
        let optionId: Option.ID
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
            }
        }
    }
}

//MARK: - Subviews

extension OptionSelectorView {
    
    struct OptionButtonView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let isSelected: Bool
        
        var body: some View {
            
            Button(
                action: { viewModel.action(viewModel.id) },
                label: label
            )
        }
        
        @ViewBuilder
        private func label() -> some View {
            
            switch viewModel.style {
            case .template:
                
                let foregroundColor = isSelected ? .white : Color(hex: "#3D3D45")
                let capsuleColor = Color(hex: isSelected ? "#3D3D45" : "#F6F6F7")
                
                Text(viewModel.title)
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().foregroundColor(capsuleColor))
                
            case .products, .productsSmall:
                
                let circleColor = isSelected ? Color.mainColorsRed : .mainColorsGrayLightest
                let textColor = isSelected ? Color.textSecondary : .textPlaceholder
                
                HStack(spacing: 4) {
                    
                    Circle()
                        .frame(width: 4, height: 4, alignment: .center)
                        .foregroundColor(circleColor)
                    
                    Text(viewModel.title)
                        .font(.textBodySM12160())
                        .foregroundColor(textColor)
                        .padding(.vertical, 6)
                }
            }
        }
    }
}

//MARK: - Preview

struct OptionSelectorView_Previews: PreviewProvider {
    
    static func previewsGroup() -> some View {
        
        Group {
            
            OptionSelectorView(viewModel: .sample)
                .previewDisplayName("style: .template")
            OptionSelectorView(viewModel: .mainSample)
                .previewDisplayName("style: .products")
            OptionSelectorView(viewModel: .mainSampleSmall)
                .previewDisplayName("style: .productsSmall")
        }
    }
    
    static var previews: some View {
        
        previewsGroup()
            .previewLayout(.fixed(width: 375, height: 40))
        
        // Xcode 14
        VStack(content: previewsGroup)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Xcode 14")
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
    
    static let mainSample = OptionSelectorView.ViewModel(
        options: .mainOptions,
        selected: "all",
        style: .products
    )
    
    static let mainSampleSmall = OptionSelectorView.ViewModel(
        options: .mainOptions,
        selected: "all",
        style: .productsSmall
    )
}

private extension Array where Element == Option {
    
    static let mainOptions: Self = [
        .init(id: "all", name: "Карты" ),
        .init(id: "add", name: "Счета"),
        .init(id: "addi", name: "Вклады"),
        .init(id: "addit", name: "Кредиты"),
        .init(id: "additi", name: "Страховка")
    ]
}
