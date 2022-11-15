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
        
        override var isFullContent: Bool {
            switch state {
            case .list(_): return true
            default: return false
            }
        }
        
        init(state: PaymentsSelectView.ViewModel.State, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.state = state
            super.init(source: source)
        }
        
        init(with parameterSelect: Payments.ParameterSelect) throws {
            
            self.state = .list([])
            super.init(source: parameterSelect)
            
            switch parameterSelect.type {
                
            case .general:
                if let selectedOptionId = parameterSelect.parameter.value,
                   let option = parameterSelect.options.first(where: {$0.id == selectedOptionId}) {
                    
                    self.state = .selected(.init(option: option, title: parameterSelect.title, action: { [weak self] in
                        self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped(itemId: option.id))
                    }))
                    
                } else {
                    
                    self.state = .list(items(options: parameterSelect.options))
                }
                
            case .banks:
                guard let selectedOptionId = parameterSelect.parameter.value,
                      let option = parameterSelect.options.first(where: {$0.id == selectedOptionId}) else {
                    
                    throw Payments.Error.missingValueForParameter(parameterSelect.parameter.id)
                }
                
                let selectedViewModel = SelectedItemViewModel(option: option, title: parameterSelect.title, action: { [weak self] in
                    self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped(itemId: option.id))
                })
                
                self.state = .selected(selectedViewModel)
                
            case .country:
                //TODO: when start country payment
                throw Payments.Error.unsupported
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
                              let option = parameterSelect.options.first(where: {$0.id == payload.itemId}) else {
                            return
                        }
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            
                            switch option.actionType {
                            case .select:
                                let selectedViewModel = SelectedItemViewModel(option: option, title: parameterSelect.title, action: { [weak self] in
                                    self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped(itemId: payload.itemId))
                                })
                                state = .selected(selectedViewModel)
                                
                            case .banks:
                                break
                                //TODO: setup action for open bottom sheet
                                
                            case .country:
                                break
                                //TODO: setup action for open bottom sheet
                            }
                        }
                        
                    case let payload as PaymentsParameterViewModelAction.Select.SelectedItemDidTapped:
                        
                        guard let parameterSelect = source as? Payments.ParameterSelect,
                              let option = parameterSelect.options.first(where: {$0.id == payload.itemId}) else {
                            return
                        }
                        
                        let selectedViewModel = SelectedItemViewModel(option: option, title: parameterSelect.title, action: { [weak self] in
                            self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped(itemId: option.id))
                        })
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            
                            switch parameterSelect.type {
                            case .general:
                                let options = parameterSelect.options.map{ Option(id: $0.id, name: $0.name)}
                                let popUpViewModel = PaymentsPopUpSelectView.ViewModel(title: selectedViewModel.title, description: nil, options: options, selected: selectedViewModel.id, action: { [weak self] optionId in
                                    
                                    self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: optionId))
                                    self?.action.send(PaymentsParameterViewModelAction.Select.PopUpSelector.Close())
                                })
                                
                                self.action.send(PaymentsParameterViewModelAction.Select.PopUpSelector.Show(viewModel: popUpViewModel))
                                
                            case .banks:
                                self.state = .unwrapped(selectedViewModel, items(options: parameterSelect.options))
                                
                            case .country:
                                self.state = .unwrapped(selectedViewModel, items(options: parameterSelect.options))
                                
                            }
                        }
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
                        
                    case .unwrapped(let selected, _):
                        update(value: selected.id)
                    }
                }
                .store(in: &bindings)
        }
        
        func items(options: [Payments.ParameterSelect.Option]) -> [ItemViewModel] {
            
            return options.map { option in
                
                let icon = option.icon.image ?? Self.itemIconPlaceholder
                let action: (ItemViewModel.ID) -> Void = { [weak self] itemId in self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId)) }
                
                return ItemViewModel(id: option.id, icon: icon, name: option.name, overlay: option.overlay, action: action)
            }
        }
        
        //MARK: ViewModel Types
        
        enum State {
            
            case list([ItemViewModel])
            case selected(SelectedItemViewModel)
            case unwrapped(SelectedItemViewModel, [ItemViewModel])
        }
        
        struct ItemViewModel: Identifiable {
            
            var id: Payments.ParameterSelect.Option.ID = UUID().uuidString
            let icon: Image
            let name: String
            let overlay: Overlay?
            let action: (ItemViewModel.ID) -> Void
            
            init(id: Payments.ParameterSelect.Option.ID = UUID().uuidString, icon: Image, name: String, overlay: Payments.ParameterSelect.Option.Overlay? = nil, action: @escaping (PaymentsSelectView.ViewModel.ItemViewModel.ID) -> Void) {
                self.id = id
                self.icon = icon
                self.name = name
                
                switch overlay {
                case .isFavorite:
                    self.overlay = .isFavorite
                
                default:
                    self.overlay = nil
                }

                self.action = action
            }
            
            enum Overlay {
                
                case isFavorite
            }
        }
        
        class SelectedItemViewModel: Identifiable {
            
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
            
            convenience init(option:  Payments.ParameterSelect.Option, title: String, action: @escaping () -> Void) {
                
                self.init(id: option.id, icon: option.icon.image ?? itemIconPlaceholder, title: title, name: option.name, action: action)
            }
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Select {
        
        enum PopUpSelector {
            
            struct Show: Action {
                
                let viewModel: PaymentsPopUpSelectView.ViewModel
            }
            
            struct Close: Action {}
        }
        
        struct SelectedItemDidTapped: Action {
            
            let itemId: Payments.ParameterSelect.Option.ID
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
                        
                        ItemViewVertical(viewModel: itemViewModel)
                            .frame(height: 56)
                    }
                }
                
            case .selected(let selectedItemViewModel):
                SelectedItemView(viewModel: selectedItemViewModel, isEditable: viewModel.isEditable)
                    .frame(minHeight: 56)
                
            case .unwrapped(let selectedItemViewModel, let items):
                SelectedItemView(viewModel: selectedItemViewModel, isEditable: viewModel.isEditable)
                    .frame(minHeight: 56)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 4) {
                        
                        ForEach(items) { itemViewModel in
                            
                            ItemViewHorizontal(viewModel: itemViewModel)
                                .frame(width: 64, alignment: .center)
                        }
                    }
                }
            }
        }
    }
    
    struct ItemViewVertical: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            HStack(spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(viewModel.name)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
        }
    }
    
    struct ItemViewHorizontal: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                ZStack {
                    
                    Circle()
                        .fill(Color.mainColorsGrayLightest)
                        .frame(width: 40, height: 40)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    switch viewModel.overlay {
                    case .isFavorite:
                        ZStack {
                            
                            Circle()
                                .foregroundColor(.mainColorsBlack)
                            
                            Image.ic24Star
                                .resizable()
                                .frame(width: 16, height: 16, alignment: .center)
                                .foregroundColor(Color.mainColorsWhite)
                            
                        }
                        .frame(width: 24, height: 24)
                        .offset(x: 20, y: -8)
                        
                    case .none:
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                }
                
                Text(viewModel.name)
                    .font(.textBodyXSR11140())
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
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
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                            .padding(.bottom, 4)
                        
                        HStack {
                            
                            Text(viewModel.name)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            Image.ic24ChevronDown
                                .frame(width: 24, height: 24)
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.bordersDivider)
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
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                            .padding(.bottom, 4)
                        
                        HStack {
                            
                            Text(viewModel.name)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.bordersDivider)
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
            
            PaymentsSelectView(viewModel: .listStateMock)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter List State")
            
            PaymentsSelectView(viewModel: .selectedStateMock)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected State")
            
            PaymentsSelectView(viewModel: .selectedParameterNotEditable)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Unwrapped State")
            
            PaymentsSelectView(viewModel: .notSelectedParameter)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsSelectView(viewModel: .selectedParameter)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsSelectView(viewModel: .selectedParameterNotEditable)
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectView.ViewModel {
    
    //MARK: viewModel state
    
    static var listStateMock: PaymentsSelectView.ViewModel = {
        
        var viewModel = PaymentsSelectView.ViewModel(state: .list([
            .init(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Сбор за пользовние объектами водными биологическими ресурсами", action: { _ in })]))
        
        return viewModel
    }()
    
    static var selectedStateMock: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let option: Payments.ParameterSelect.Option = .init(id: "id", name: "Транспортный налог", icon: icon)
        
        var viewModel = PaymentsSelectView.ViewModel(state: .selected(.init(option: option, title: "Транспортный налог", action: {})))
        
        return viewModel
    }()
    
    static var unwrappedStateMock: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let firstItem = PaymentsSelectView.ViewModel.ItemViewModel(icon: Image("Payments List Sample"), name: "Имущественный налог", action: { _ in })
        
        var viewModel = PaymentsSelectView.ViewModel.init(state: .unwrapped(.init(option: .init(id: "id", name: "Имущественный налог", icon: icon), title: "Имущественный налог", action: {}), [
            firstItem,
            .init(icon: Image("Payments List Sample"), name: "Транспортный налог", action: { _ in }),
            .init(icon: Image("Payments List Sample"), name: "Земельный налог", action: { _ in })]))
        
        return viewModel
    }()
    
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect( .init(id: UUID().uuidString, value: nil), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        let viewModel = try! PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
    
    static var selectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = try! PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
    
    static var selectedParameterNotEditable: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)], isEditable: false)
        
        var viewModel = try! PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
}

