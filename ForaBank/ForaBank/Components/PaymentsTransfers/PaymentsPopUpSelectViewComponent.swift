//
//  PaymentsPopUpSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsPopUpSelectView {
    
    class ViewModel: ObservableObject, Identifiable {
    
        let id = UUID()
        let title: String
        let description: String?
        var items: [ItemViewModel]
        @Published var selected: Option.ID?
        let action: (Option.ID) -> Void
        
        private var bindings: Set<AnyCancellable> = []
        
        internal init(title: String, description: String?, items: [ItemViewModel], selected: Option.ID?, action: @escaping (Option.ID) -> Void) {
            
            self.title = title
            self.description = description
            self.items = items
            self.selected = selected
            self.action = action
        }
        
        convenience init(title: String, description: String?, options: [Option],
             selected: Option.ID? = nil,
             action: @escaping (Option.ID) -> Void) {
            
            self.init(title: title, description: description, items: [], selected: selected, action: action)
            
            
            self.items = options.map { ItemViewModel(id: $0.id, name: $0.name, subtitle: $0.subtitle, isSelected: false, icon: .circle($0.id), action: {[weak self] itemId in
                
                if let option = options.first(where: {$0.id == itemId}) {
                    
                    
                    self?.selected = option.id
                }
            }) }
            
            self.bind()
        }
        
        func bind() {
            
            $selected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selected in
                    
                    for item in items {
                        
                        item.isSelected = item.id == selected ? true : false
                    }
                    
                }.store(in: &bindings)
            
            $selected
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selected in
                    
                    guard let selected = selected else { return }
                    action(selected)
                    
                }.store(in: &bindings)
        }
        
        class ItemViewModel: Identifiable, ObservableObject {
            
            let id: Option.ID
            let name: String
            let subtitle: String?
            let icon: IconViewModel
            let action: (Option.ID?) -> Void
            @Published var isSelected: Bool
            
            init(id: String, name: String, subtitle: String? = nil, isSelected: Bool, icon: IconViewModel, action: @escaping (String?) -> Void) {
                
                self.id = id
                self.name = name
                self.subtitle = subtitle
                self.isSelected = isSelected
                self.icon = icon
                self.action = action
            }
            
            enum IconViewModel {
                
                case circle(String)
                case selector
            }
        }
    }
}

//MARK: - View

struct PaymentsPopUpSelectView: View {
    
    var viewModel: PaymentsPopUpSelectView.ViewModel
    var isCompact: Bool { viewModel.items.count < 8 }
    
    var body: some View {
                
        VStack(alignment: .leading, spacing: 16) {
            
            Text(viewModel.title)
                .foregroundColor(.textSecondary)
                .font(.textH3SB18240())
            
            if let description = viewModel.description {
                
                Text(description)
                    .foregroundColor(.textPlaceholder)
                    .font(.textBodyMR14200())
            }
            
            if isCompact == true {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.items) { item in
                        
                        ItemView(viewModel: item)
                    }
                    
                    Color.clear
                        .frame(height: 60)
                }
                
            } else {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(viewModel.items) { item in
                            
                            ItemView(viewModel: item)
                        }
                        
                        Color.clear
                            .frame(height: 60)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    struct ItemView: View {
        
        @ObservedObject var viewModel: ViewModel.ItemViewModel
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .top, spacing: 24) {
                    
                    IconView(viewModel: viewModel)

                    VStack {
                        Spacer()
                        Text(viewModel.name)
                            .foregroundColor(.textSecondary)
                            .font(.textBodyMR14200())
                            .frame(alignment: .center)
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                if let subtitle = viewModel.subtitle {

                    HStack(spacing: 24) {

                        Color.clear
                            .frame(width: 24, height: 24)

                        Text(subtitle)
                            .foregroundColor(.textPlaceholder)
                            .font(.textBodySM12160())
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                }
                
            }
            .frame(height: 40, alignment: .center)
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
        }
    }
    
    struct IconView: View {
        
        let viewModel: PaymentsPopUpSelectView.ViewModel.ItemViewModel
        
        var body: some View {
        
            switch viewModel.icon {
            case let .circle(symbol):
                
                ZStack {
                    
                    Circle()
                        .frame(width: 40, height: 40, alignment: .center)
                        .foregroundColor(.mainColorsBlack)
                    
                    Text(symbol)
                        .foregroundColor(.mainColorsWhite)
                        .frame(alignment: .center)
                }
                
            case .selector:
                if viewModel.isSelected == true {
                    
                    Image("Payments Icon Circle Selected")
                        .frame(width: 24, height: 24)
                    
                } else {
                    
                    Image("Payments Icon Circle Empty")
                        .frame(width: 24, height: 24)
                }
            }
            
        }
    }
}

//MARK: - Preview

struct PaymentsPopUpSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsPopUpSelectView(viewModel: sample)
            .previewLayout(.fixed(width: 375, height: 500))
    }
}

//MARK: - Preview Content

extension PaymentsPopUpSelectView_Previews {
    
    static let sample = PaymentsPopUpSelectView.ViewModel(
        title: "Выберите значение",
        description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
        items: [.init(id: "0", name: "В возрасте от 14 лет", isSelected: true, icon: .selector, action: {_ in }),
                .init(id: "1", name: "В возрасте до 14 лет", isSelected: false, icon: .selector, action: {_ in }),
                .init(id: "2", name: "В возрасте до 14 лет (новый образец)", isSelected: false, icon: .selector, action: {_ in }),
                .init(id: "3", name: "Содержащего электронный носитель информации (паспорта нового поколения)", isSelected: false, icon: .selector, action: {_ in }),
                .init(id: "4", name: "За внесение изменений в паспорт", subtitle: "12329823", isSelected: false, icon: .selector, action: {_ in })], selected: "0", action: { _ in })
}
