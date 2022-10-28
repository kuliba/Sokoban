//
//  PaymentsSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsSelectView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        @Published var state: State
    
        private var bindings: Set<AnyCancellable> = []
        
        //TODO: real placeholder required
        private static let itemIconPlaceholder = Image("Payments Icon Placeholder")
        
        internal init(items: [ItemViewModel], description: String, selected: (item: ItemViewModel, action: () -> Void)? = nil) {
            
            if let selected = selected {
                
                self.state = .selected(.init(with: selected.item, description: description, action: selected.action))
                
            } else {
                
                self.state = .list(items)
            }

            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterSelect: Payments.ParameterSelect) {

            self.state = .list([])
            super.init(source: parameterSelect)
            
            if let selectedOptionId = parameterSelect.parameter.value {
                
                if let selectedViewModel = selected(options: parameterSelect.options, selectedId: selectedOptionId, title: parameterSelect.title)  {
                    
                    self.state = .selected(selectedViewModel )
                    
                } else {
                    
                    self.state = .list(items(options: parameterSelect.options))
                }

            } else {
                
                self.state = .list(items(options: parameterSelect.options))
            }
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsParameterViewModelAction.Select.DidSelected:
                        guard let parameterSelect = source as? Payments.ParameterSelect,
                        let selectedViewModel = selected(options: parameterSelect.options, selectedId: payload.itemId, title: parameterSelect.title) else {
                            return
                        }
                        
                        state = .selected(selectedViewModel)
     
                    default:
                        break
                    }
                }
                .store(in: &bindings)
            
            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    switch state {
                    case .selected(let selected):
                        update(value: selected.id)
                        
                    case .list:
                        update(value: nil)
                    }
                }
                .store(in: &bindings)
        }
        
        func items(options: [Payments.ParameterSelect.Option]) -> [ItemViewModel] {
            
            return options.map { option in
                
                let icon = option.icon.image ?? Self.itemIconPlaceholder
                let action: (ItemViewModel.ID) -> Void = { [weak self] itemId in self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId)) }
                
                return ItemViewModel(id: option.id, icon: icon, name: option.name, action: action)
            }
        }
        
        func selected(options: [Payments.ParameterSelect.Option], selectedId: Payments.Parameter.ID, title: String) -> SelectedItemViewModel? {
            
            guard let selectedOption = options.first(where: { $0.id == selectedId }) else {
                return nil
            }
            
            let icon = selectedOption.icon.image ?? Self.itemIconPlaceholder
            
            let options = options.map{ Option(id: $0.id, name: $0.name)}
            let popUpViewModel = PaymentsPopUpSelectView.ViewModel(title: title, description: nil, options: options, selected: selectedId, action: { [weak self] optionId in
                
                self?.update(value: optionId)
            })

            return SelectedItemViewModel(id: selectedOption.id, icon: icon, title: title, name: selectedOption.name, action: { [weak self] in self?.action.send(PaymentsParameterViewModelAction.Select.OptionExternal(viewModel: popUpViewModel)) })
        }
        
        //MARK: ViewModel Types
        
        enum State {
            
            case list([ItemViewModel])
            case selected(SelectedItemViewModel)
        }
        
        struct ItemViewModel: Identifiable {
            
            var id: Payments.ParameterSelect.Option.ID = UUID().uuidString
            let icon: Image
            let name: String
            let action: (ItemViewModel.ID) -> Void
        }
        
        struct SelectedItemViewModel: Identifiable {
      
            let id: Payments.ParameterSelect.Option.ID
            let icon: Image
            let title: String
            let name: String
            let action: () -> Void
            
            internal init(id: Payments.ParameterSelect.Option.ID, icon: Image, title: String, name: String, action: @escaping () -> Void) {
               
                self.id = id
                self.icon = icon
                self.title = title
                self.name = name
                self.action = action
            }
            
            init(with item: ItemViewModel, description: String, action: @escaping () -> Void) {
                
                self.id = item.id
                self.icon = item.icon
                self.name = item.name
                self.title = description
                self.action = action
            }
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum Select {
    
        struct OptionExternal: Action {
            
            let viewModel: PaymentsPopUpSelectView.ViewModel
        }
        
        struct DidSelected: Action {
            
            let itemId: Payments.ParameterSelect.Option.ID
        }
    }
}

//MARK: - View

struct PaymentsSelectView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            switch viewModel.state {
            case .list(let items):
                VStack(spacing: 0) {
                    
                    ForEach(items) { itemViewModel in
    
                        ItemView(viewModel: itemViewModel)
                            .frame(height: 56)
                    }
                }
                
            case .selected(let selectedItemViewModel):
                SelectedItemView(viewModel: selectedItemViewModel, isEditable: viewModel.isEditable)
                    .frame(minHeight: 56)
            }
        }
    }
    
    struct ItemView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            HStack(spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(viewModel.name)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(Color(hex: "#1C1C1C"))
                
                Spacer()
            }
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
        }
    }
    
    struct SelectedItemView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.SelectedItemViewModel
        let isEditable: Bool
        
        var body: some View {
            
            if isEditable == true {
                
                HStack(spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .font(Font.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.bottom, 4)
                        
                        HStack {
                            
                            Text(viewModel.name)
                                .font(Font.custom("Inter-Medium", size: 14))
                                .foregroundColor(Color(hex: "#1C1C1C"))
                            
                            Spacer()
                            
                            Image("chevron-downnew")
                                .frame(width: 24, height: 24)
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                            .padding(.top, 12)
                    }
                }
                .onTapGesture {
                    
                    viewModel.action()
                }
                
            } else {
                
                HStack(spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .font(Font.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.bottom, 4)
                        
                        HStack {
                            
                            Text(viewModel.name)
                                .font(Font.custom("Inter-Medium", size: 14))
                                .foregroundColor(Color(hex: "#1C1C1C"))
                            
                            Spacer()
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                            .opacity(0.2)
                            .padding(.top, 12)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSelectView(viewModel: .notSelectedParameter)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Not Selected")
            
            PaymentsSelectView(viewModel: .selectedParameter)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected")
            
            PaymentsSelectView(viewModel: .selectedParameterNotEditable)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected Not Editable")
            
            PaymentsSelectView(viewModel: .notSelectedMock)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsSelectView(viewModel: .selectedMock)
                .previewLayout(.fixed(width: 375, height: 100))
            
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectView.ViewModel {
    
    static var notSelectedMock: PaymentsSelectView.ViewModel = {
        
        var viewModel = PaymentsSelectView.ViewModel(items: [
            .init(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Сбор за пользовние объектами водными биологическими ресурсами", action: { _ in })], description: "Категория платежа")
        
        return viewModel
    }()
    
    static var selectedMock: PaymentsSelectView.ViewModel = {
        
        let firstItem = PaymentsSelectView.ViewModel.ItemViewModel(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in })
        
        var viewModel = PaymentsSelectView.ViewModel(items: [
            firstItem,
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Земельный налог", action: { _ in })], description: "Категория платежа", selected: (firstItem, {}))
        
        return viewModel
    }()
   
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect( .init(id: UUID().uuidString, value: nil), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
    
    static var selectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
    
    static var selectedParameterNotEditable: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)], isEditable: false)
        
        var viewModel = PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
}

