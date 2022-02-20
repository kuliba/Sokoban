//
//  PaymentsParameterSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI
import RealmSwift
import Combine

//MARK: - ViewModel

extension PaymentsParameterSelectView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var state: State
    
        private var bindings: Set<AnyCancellable> = []
        //TODO: real placeholder required
        private static let itemIconPlaceholder = Image("Payments Icon Placeholder")
        
        internal init(items: [ItemViewModel], description: String, selected: (item: ItemViewModel, action: () -> Void)? = nil, parameter: Payments.Parameter = .init(id: UUID().uuidString, value: "")) {
            
            if let selected = selected {
                
                self.state = .selected(.init(with: selected.item, description: description, action: selected.action))
                
            } else {
                
                self.state = .list(items)
            }

            super.init(parameter: parameter)
        }
        
        init(with parameterSelect: Payments.ParameterSelect) throws {

            self.state = .list([])
            super.init(parameter: parameterSelect)
            
            if let selectedOptionId = parameterSelect.value {
                
                self.state = .selected(try selected(options: parameterSelect.options, selectedId: selectedOptionId, title: parameterSelect.title))
                
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
                    case let payload as PaymentsParameterSelectView.ViewModelAction.ItemSelected:
                        guard let parameterSelect = parameter as? Payments.ParameterSelect else {
                            return
                        }
                        do {
                            
                            state = .selected(try selected(options: parameterSelect.options, selectedId: payload.itemId, title: parameterSelect.title))
                            
                        } catch {
                            
                           //TODO: log error
                            print(error.localizedDescription)
                        }
  
                    default:
                        break
                    }
                }
                .store(in: &bindings)
        }
        
        func items(options: [Payments.ParameterSelect.Option]) -> [ItemViewModel] {
            
            return options.map { option in
                
                let icon = option.icon.image ?? Self.itemIconPlaceholder
                let action: (ItemViewModel.ID) -> Void = { [weak self] itemId in self?.action.send(PaymentsParameterSelectView.ViewModelAction.ItemSelected(itemId: itemId)) }
                
                return ItemViewModel(id: option.id, icon: icon, name: option.name, action: action)
            }
        }
        
        func selected(options: [Payments.ParameterSelect.Option], selectedId: Payments.Parameter.ID, title: String) throws -> SelectedItemViewModel {
            
            guard let selectedOption = options.first(where: { $0.id == selectedId }) else {
                throw Error.unableSelectItemWithId(selectedId)
            }
            
            let icon = selectedOption.icon.image ?? Self.itemIconPlaceholder
            return SelectedItemViewModel(id: selectedOption.id, icon: icon, title: title, name: selectedOption.name, action: { [weak self] in self?.action.send(PaymentsParameterSelectView.ViewModelAction.ShowItemsList()) })
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
        
        enum Error: Swift.Error {
            
            case unableSelectItemWithId(Payments.Parameter.ID)
        }
    }
    
    enum ViewModelAction {
        
        struct ItemSelected: Action {
            
            let itemId: Payments.ParameterSelect.Option.ID
        }
        
        struct ShowItemsList: Action {}
    }
}

//MARK: - View

struct PaymentsParameterSelectView: View {
    
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
                SelectedItemView(viewModel: selectedItemViewModel)
                    .frame(minHeight: 56)
            }
        }
    }
    
    struct ItemView: View {
        
        let viewModel: PaymentsParameterSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            HStack(spacing: 21) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                
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
        
        let viewModel: PaymentsParameterSelectView.ViewModel.SelectedItemViewModel
        
        var body: some View {
            
            HStack(spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                
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
                        .foregroundColor(Color(hex: "#EAEBEB"))
                        .padding(.top, 12)
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsParameterSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsParameterSelectView(viewModel: .notSelectedParameter)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Not Selected")
            
            PaymentsParameterSelectView(viewModel: .selectedParameter)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected")
            
            PaymentsParameterSelectView(viewModel: .notSelectedMock)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsParameterSelectView(viewModel: .selectedMock)
                .previewLayout(.fixed(width: 375, height: 100))
            
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterSelectView.ViewModel {
    
    static var notSelectedMock: PaymentsParameterSelectView.ViewModel = {
        
        var viewModel = PaymentsParameterSelectView.ViewModel(items: [
            .init(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Сбор за пользовние объектами водными биологическими ресурсами", action: { _ in })], description: "Категория платежа")
        
        return viewModel
    }()
    
    static var selectedMock: PaymentsParameterSelectView.ViewModel = {
        
        let firstItem = PaymentsParameterSelectView.ViewModel.ItemViewModel(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in })
        
        var viewModel = PaymentsParameterSelectView.ViewModel(items: [
            firstItem,
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Земельный налог", action: { _ in })], description: "Категория платежа", selected: (firstItem, {}))
        
        return viewModel
    }()
   
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsParameterSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(value: .init(id: UUID().uuidString, value: nil), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = try! PaymentsParameterSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
    
    static var selectedParameter: PaymentsParameterSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(value: .init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = try! PaymentsParameterSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
}

