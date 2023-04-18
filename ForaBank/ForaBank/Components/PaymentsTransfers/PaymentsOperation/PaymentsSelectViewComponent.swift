//
//  PaymentsSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI
import Combine
import TextFieldRegularComponent

//MARK: - ViewModel

extension PaymentsSelectView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {

        @Published var state: State
        override var isValid: Bool { value.current != nil }
        
        init(state: PaymentsSelectView.ViewModel.State, source: PaymentsParameterRepresentable) {
            
            self.state = state
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelect) {
            
            if let value = parameterSelect.value,
               let selectedOption = parameterSelect.options.first(where: { $0.id == value } ) {

                self.init(state: .selected(.init(option: selectedOption, title: parameterSelect.title, parameterIcon: parameterSelect.icon)), source: parameterSelect)
   
            } else {
                
                self.init(state: .list(.init(parameterSelect: parameterSelect, selectedOptionId: nil)), source: parameterSelect)
            }
            
            bind()
        }
    }
}

//MARK: - Calculated properties

extension PaymentsSelectView.ViewModel {

    private var parameterSelect: Payments.ParameterSelect? { source as? Payments.ParameterSelect }
}

//MARK: - Bindings

extension PaymentsSelectView.ViewModel {
    
    private func bind() {
        
        $state
            .compactMap({ (state) -> OptionsListViewModel? in
                
                guard case let .list(optionsListViewModel) = state else {
                    return nil
                }
                
                return optionsListViewModel
            })
            .flatMap(\.action)
            .compactMap { $0 as? PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected }
            .map(\.optionId)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] optionId in
                
                guard let parameterSelect = parameterSelect,
                      let selectedOption = parameterSelect.options.first(where: { $0.id == optionId }) else {
                    return
                }
                
                update(value: optionId)
                
                withAnimation {
                    state = .selected(.init(option: selectedOption, title: parameterSelect.title, parameterIcon: parameterSelect.icon))
                }

            }.store(in: &bindings)

        action
            .compactMap { $0 as? PaymentsParameterViewModelAction.Select.ToggleList }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelect = parameterSelect else {
                    return
                }
                
                switch state {
                case .selected:
                    
                    withAnimation {
                        
                        state = .list(.init(parameterSelect: parameterSelect, selectedOptionId: value.current))
                    }
                    
                case .list:
                    
                    guard let selectedOption = parameterSelect.options.first(where: { $0.id == value.current }) else {
                        return
                    }
                    
                    withAnimation {
                        
                        state = .selected(.init(option: selectedOption, title: parameterSelect.title, parameterIcon: parameterSelect.icon))
                    }
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension PaymentsSelectView.ViewModel {
    
    enum State {
        
        case selected(SelectedOptionViewModel)
        case list(OptionsListViewModel)
    }
    
    struct SelectedOptionViewModel {

        let icon: IconViewModel
        let title: String
        let name: String
        
        init(icon: IconViewModel, title: String, name: String) {
            
            self.icon = icon
            self.title = title
            self.name = name
        }
        
        init(option: Payments.ParameterSelect.Option, title: String, parameterIcon: Payments.ParameterSelect.Icon?) {
            
            self.init(icon: .init(with: option, and: parameterIcon), title: title, name: option.name)
        }
    }
    
    //TODO: extract to reusable component
    enum IconViewModel: Equatable {
        
        case image32(Image)
        case image24(Image)
        case placeholder
    }
}

//MARK: - Convenience inits

extension PaymentsSelectView.ViewModel.IconViewModel {
    
    init(with parameterIcon: Payments.ParameterSelect.Icon?) {
        
        switch parameterIcon {
        case let .some(icon):
            switch icon {
            case let .image(imageData):
                switch imageData.image {
                case let .some(image):
                    self = .image32(image)
                    
                case .none:
                    self = .placeholder
                }

            case let .name(iconName):
                self = .image24(Image(iconName))
            }
            
        case .none:
            self = .placeholder
        }
    }
    
    init(with option: Payments.ParameterSelect.Option, and parameterIcon: Payments.ParameterSelect.Icon?) {
        
        switch option.icon {
        case let .image(imageData):
            switch imageData.image {
            case let .some(image):
                self = .image32(image)
                
            case .none:
                self = .placeholder
            }
            
        case .circle:
            self = .init(with: parameterIcon)
        }
    }
}

//MARK: - Options List View Model

extension PaymentsSelectView.ViewModel {
    
    class OptionsListViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        let icon: IconViewModel
        let title: String
        let textField: TextFieldRegularView.ViewModel
        @Published var filterred: [OptionViewModel]
        let selected: OptionViewModel.ID?
        
        private let options: [OptionViewModel]
        private var bindings: Set<AnyCancellable> = []
        
        init(icon: IconViewModel, title: String, textField: TextFieldRegularView.ViewModel, filterred: [OptionViewModel], options: [OptionViewModel], selected: OptionViewModel.ID?) {
            
            self.icon = icon
            self.title = title
            self.textField = textField
            self.filterred = filterred
            self.options = options
            self.selected = selected
        }
        
        convenience init(parameterSelect: Payments.ParameterSelect, selectedOptionId: OptionViewModel.ID?) {
            
            let optionsViewModels = parameterSelect.options.map { OptionViewModel(option: $0) }
            if let selectedOption = parameterSelect.options.first(where: { $0.id == selectedOptionId }) {
                
                self.init(icon: .init(with: selectedOption, and: parameterSelect.icon),
                          title: parameterSelect.title,
                          textField: .init(text: nil, placeholder: selectedOption.name, keyboardType: .default, limit: nil),
                          filterred: optionsViewModels,
                          options: optionsViewModels,
                          selected: selectedOption.id)
            } else {
                
                self.init(
                    icon: .init(with: parameterSelect.icon),
                    title: parameterSelect.title,
                    textField: .init(text: nil, placeholder: parameterSelect.placeholder, keyboardType: .default, limit: nil),
                    filterred: optionsViewModels,
                    options: optionsViewModels,
                    selected: nil)
            }
            
            bind()
        }
        
        func optionSelected(optionId: PaymentsSelectView.ViewModel.OptionViewModel.ID) {
            
            action.send(PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected(optionId: optionId))
        }
        
        func bind() {
            
            textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    withAnimation {
                        
                        if let text = text, text != "" {
                            
                            filterred = PaymentsSelectView.ViewModel.reduce(options: options, filter: text)
                            
                        } else {
                            
                            filterred = options
                        }
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    struct OptionViewModel: Identifiable, Equatable {
        
        let id: String
        let icon: IconViewModel
        let name: String
        let subname: String?
        let timeWork: String?
        let currencies: [Currency]?
        
        init(id: String, icon: IconViewModel, name: String, subname: String? = nil, timeWork: String? = nil, currencies: [Currency]? = nil) {
            
            self.id = id
            self.icon = icon
            self.name = name
            self.subname = subname
            self.timeWork = timeWork
            self.currencies = currencies
        }
        
        init(option: Payments.ParameterSelect.Option) {
            
            self.init(id: option.id, icon: .init(with: option.icon), name: option.name, subname: option.subname, timeWork: option.timeWork, currencies: option.currencies?.map({ Currency(icon: .ic12Coins, currency: $0) }))
        }
        
        enum IconViewModel: Equatable {
            
            case image(Image)
            case circle
            
            init(with icon: Payments.ParameterSelect.Option.Icon) {
                
                switch icon {
                case let .image(imageData):
                    if let image = imageData.image {
                        
                        self = .image(image)
                        
                    } else {
                        
                        self  = .circle
                    }

                case .circle:
                    self = .circle
                }
            }
        }
        
        struct Currency: Identifiable, Equatable {
            
            let id = UUID()
            let icon: Image
            let currency: String
        }
    }
}

//MARK: - Reducers

extension PaymentsSelectView.ViewModel {
    
    static func reduce(options: [OptionViewModel], filter: String) -> [OptionViewModel] {
        
        options.filter { optionViewModel in
            
            optionViewModel.name.lowercased().contained(in: [filter.lowercased()])
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Select {
        
        struct ToggleList: Action {}
        
        struct SelectedItemDidTapped: Action {}
        
        struct DidSelected: Action {
            
            let itemId: Payments.ParameterSelect.Option.ID
        }
        
        enum OptionsList {
            
            struct OptionSelected: Action {
                
                let optionId: PaymentsSelectView.ViewModel.OptionViewModel.ID
            }
        }
    }
}

//MARK: - View

struct PaymentsSelectView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Namespace var namespace
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.state {
            case let .selected(selectedOptionViewModel):
                SelectedOptionView(viewModel: selectedOptionViewModel, namespace: namespace) {
                    viewModel.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
                }

            case let .list(optionsListViewModel):
                OptionsListView(viewModel: optionsListViewModel, namespace: namespace) {
                    viewModel.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
    }
}

//MARK: - Internal Views

extension PaymentsSelectView {
    
    struct SelectedOptionView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.SelectedOptionViewModel
        var namespace: Namespace.ID
        let toggleAction: () -> Void
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 12) {
                
                PaymentsSelectView.IconView(viewModel: viewModel.icon)
                    .padding(.top, 6)
                    .matchedGeometryEffect(id: "icon", in: namespace)
 
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                        .matchedGeometryEffect(id: "title", in: namespace)
                    
                    Text(viewModel.name)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image.ic24ChevronDown
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
            }
            .contentShape(Rectangle())
            .onTapGesture { toggleAction() }
        }
    }
    
    struct OptionsListView: View {
    
        @ObservedObject var viewModel: PaymentsSelectView.ViewModel.OptionsListViewModel
        var namespace: Namespace.ID
        let toggleAction: () -> Void
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    PaymentsSelectView.IconView(viewModel: viewModel.icon)
                        .padding(.top, 6)
                        .matchedGeometryEffect(id: "icon", in: namespace)
                  
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .foregroundColor(.textPlaceholder)
                            .font(.textBodyMR14180())
                            .matchedGeometryEffect(id: "title", in: namespace)
                        
                        TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16), backgroundColor: Color.clear, tintColor: .textSecondary, textColor: .textSecondary)
                    }
                    
                    Spacer()
                    
                    if viewModel.selected != nil {

                        Button(action: toggleAction) {
                            
                            Image.ic24ChevronUp
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(.iconGray)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.filterred) { optionViewModel in
                            
                            PaymentsSelectView.OptionView(viewModel: optionViewModel, isSelected: optionViewModel.id == viewModel.selected) {
                                viewModel.optionSelected(optionId: optionViewModel.id)
                            }
                            
                            if optionViewModel.id != viewModel.filterred.last?.id {
                                
                                Divider()
                                    .padding(.leading, 46)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                }
                .frame(maxHeight: 350)
            }
        }
    }
    
    //TODO: extract to reusable component
    struct IconView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.IconViewModel
        
        var body: some View {
            
            Group {
                
                switch viewModel {
                case let .image32(image):
                    image
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                case let .image24(image):
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                    
                case .placeholder:
                    Color.clear
                }
                
            }.frame(width: 32, height: 32)
        }
    }
    struct OptionView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.OptionViewModel
        let isSelected: Bool
        let selectAction: () -> Void

        var body: some View {
            
            VStack {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    Group {
                        
                        switch viewModel.icon {
                        case .circle:
                            
                            if isSelected {
                                //TODO: load icons from StyleGuide
                                Image("Payments Icon Circle Selected")
                                    .frame(width: 24, height: 24)
                            } else {
                                
                                Image("Payments Icon Circle Empty")
                                    .frame(width: 24, height: 24)
                            }
                            
                        case let .image(image):
                            image
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                    }
                    .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.name)
                            .font(.textH4M16240())
                            .foregroundColor(.textSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        
                        if let description = viewModel.subname {
                            
                            Text(description)
                                .font(.textH4R16240())
                                .foregroundColor(.textPlaceholder)
                                .frame(width: .infinity)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let workingTime = viewModel.timeWork {
                            
                            Text(workingTime)
                                .font(.textH4R16240())
                                .foregroundColor(.mainColorsBlack)
                                .frame(width: .infinity)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let currencies = viewModel.currencies, currencies.isEmpty == false {
                            
                            HStack {
                                
                                ForEach(currencies, id: \.id) { currency in
                                    
                                    HStack {
                                        
                                        currency.icon
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.mainColorsGray)
                                        
                                        Text(currency.currency)
                                            .foregroundColor(.mainColorsGray)
                                            .font(.textH4R16240())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { selectAction() }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsGroupView(viewModel: PaymentsSelectView.ViewModel.emptySelection)
                .previewDisplayName("Empty Selection")
            
            PaymentsGroupView(viewModel: PaymentsSelectView.ViewModel.selected)
                .previewDisplayName("Selected")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectView.ViewModel {
    
    static let emptySelection = PaymentsGroupViewModel(items: [
        
        PaymentsSelectView.ViewModel(
            with: .init(
                .init(
                    id: UUID().uuidString,
                    value: nil),
                icon: .name("ic24Bank"),
                title: "Тип оплаты",
                placeholder: "Выберете тип",
                options: [
                    .init(id: "0", name: "Оплата наличными"),
                    .init(id: "1", name: "Оплата переводом"),
                    .init(id: "2", name: "Длинный, очень длинный текст для отладки анимации при выборе данной опции")
                ]))
    ])
    
    static let selected = PaymentsGroupViewModel(items: [
        
        PaymentsSelectView.ViewModel(
            with: .init(
                .init(
                    id: UUID().uuidString,
                    value: "0"),
                icon: .name("ic24MapPin"),
                title: "Тип оплаты",
                placeholder: "Выберете тип",
                options: [
                    .init(id: "0", name: "Оплата наличными"),
                    .init(id: "1", name: "Оплата переводом"),
                    .init(id: "2", name: "Длинный, очень длинный текст для отладки анимации при выборе данной опции")
                ]))
    ])
    
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect.init(Payments.Parameter.init(id: "", value: nil), title: "Тип услуги", placeholder: "Начните ввод для поиска", options: [])
        
        let viewModel = PaymentsSelectView.ViewModel(with: parameter)
        
        return PaymentsSelectView.ViewModel(with: parameter)
    }()
    
    static var selectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(Payments.Parameter.init(id: "", value: "Имущественный налог"), title: "Тип услуги", placeholder: "Начните ввод для поиска", options: [])
        
        var viewModel = PaymentsSelectView.ViewModel(with: parameter)
        
        return viewModel
    }()
}
