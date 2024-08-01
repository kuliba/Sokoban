//
//  PaymentsSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

//MARK: - ViewModel

extension PaymentsSelectView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {

        @Published var state: State
        
        init(state: PaymentsSelectView.ViewModel.State, source: PaymentsParameterRepresentable) {
            
            self.state = state
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelect) {
            
            if let value = parameterSelect.value,
               let selectedOptionViewModel = SelectedOptionViewModel(value: value, parameter: parameterSelect) {

                self.init(state: .selected(selectedOptionViewModel), source: parameterSelect)
   
            } else {
                
                self.init(state: .list(.init(parameterSelect: parameterSelect, selectedOptionId: nil)), source: parameterSelect)
            }
            
            bind()
        }
        
        //MARK: - Overrides
        
        override var isValid: Bool { value.current != nil }
    }
}

//MARK: - Calculated properties

extension PaymentsSelectView.ViewModel {

    private var parameterSelect: Payments.ParameterSelect? { source as? Payments.ParameterSelect }
}

//MARK: - Bindings

extension PaymentsSelectView.ViewModel {
    
    private func bind() {
        
        Publishers
            .CombineLatest(
                action.compactMap( { $0 as? PaymentsParameterViewModelAction.Select.ToggleList } ),
                $isEditable.removeDuplicates()
            )
            .map(\.1)
            .filter({ $0 })
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
                    
                    guard let selectedOptionViewModel = SelectedOptionViewModel(value: value.current, parameter: parameterSelect) else {
                        return
                    }
                    
                    withAnimation {
                        
                        state = .selected(selectedOptionViewModel)
                    }
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected }
            .map(\.optionId)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] optionId in
                
                guard let parameterSelect = parameterSelect,
                      let selectedOptionViewModel = SelectedOptionViewModel(value: optionId, parameter: parameterSelect) else {
                    return
                }
                
                update(value: optionId)
                
                withAnimation {
                    state = .selected(selectedOptionViewModel)
                }

            }.store(in: &bindings)
        
        $isEditable
            .dropFirst()
            .removeDuplicates()
            .filter({ !$0 })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelect = parameterSelect,
                let selectedOptionViewModel = SelectedOptionViewModel(value: value.current, parameter: parameterSelect) else {
                    return
                }

                withAnimation {
                    
                    state = .selected(selectedOptionViewModel)
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
        
        init?(value: Payments.Parameter.Value, parameter: Payments.ParameterSelect) {
            
            guard let selectedOption = parameter.options.first(where: { $0.id == value }) else {
                return nil
            }
            
            self.init(icon: .init(with: selectedOption, and: parameter.icon), title: parameter.title, name: selectedOption.name)
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
        
        let icon: IconViewModel
        let title: String
        let textField: RegularFieldViewModel
        @Published var filtered: [OptionViewModel]
        let selected: OptionViewModel.ID?
        
        private let options: [OptionViewModel]
        private var bindings: Set<AnyCancellable> = []
        
        init(icon: IconViewModel, title: String, textField: RegularFieldViewModel, filtered: [OptionViewModel], options: [OptionViewModel], selected: OptionViewModel.ID?) {
            
            self.icon = icon
            self.title = title
            self.textField = textField
            self.filtered = filtered
            self.options = options
            self.selected = selected
        }
        
        convenience init(parameterSelect: Payments.ParameterSelect, selectedOptionId: OptionViewModel.ID?) {
            
            let viewModel = Self.createViewModel(parameterSelect: parameterSelect, selectedOptionId: selectedOptionId)
            
            self.init(
                icon: viewModel.icon,
                title: viewModel.title,
                textField: viewModel.textField,
                filtered: viewModel.filtered,
                options: viewModel.options,
                selected: viewModel.selected
            )
            
            bind()
        }
        
        func bind() {
            
            textField.textPublisher()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    withAnimation {
                        
                        switch text {
                        case let .some(value):
                            switch value {
                            case "":
                                filtered = options
                                
                            default:
                                filtered = PaymentsSelectView.ViewModel.reduce(options: options, filter: value)
                            }
                            
                        case .none:
                            filtered = options
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        func isDisabledTF(_ title: String) -> Bool {
            
            title == Payments.ParameterSelect.kppTitle
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
            
            var id: String { currency }
            let icon: Image
            let currency: String
        }
    }
}

extension PaymentsSelectView.ViewModel.OptionsListViewModel {
    
    private static func createViewModel(
        parameterSelect: Payments.ParameterSelect,
        selectedOptionId: PaymentsSelectView.ViewModel.OptionViewModel.ID?
    ) -> PaymentsSelectView.ViewModel.OptionsListViewModel {
        
        let optionsViewModels = parameterSelect.options.map { PaymentsSelectView.ViewModel.OptionViewModel(option: $0) }
        
        if let selectedOption = parameterSelect.options.first(where: { $0.id == selectedOptionId }) {
            
            let textField = makeTextField(parameterSelect: parameterSelect, selectedOption: selectedOption)
            
            return .init(
                icon: .init(with: selectedOption, and: parameterSelect.icon),
                title: parameterSelect.title,
                textField: textField,
                filtered: optionsViewModels,
                options: optionsViewModels,
                selected: selectedOption.id
            )
            
        } else {
            
            let textField = makeTextField(parameterSelect: parameterSelect, selectedOption: nil)
            
            return .init(
                icon: .init(with: parameterSelect.icon),
                title: parameterSelect.title,
                textField: textField,
                filtered: optionsViewModels,
                options: optionsViewModels,
                selected: nil
            )
        }
    }
    
    private static func makeTextField(
        parameterSelect: Payments.ParameterSelect,
        selectedOption: Payments.ParameterSelect.Option?
    ) -> RegularFieldViewModel {
        
        let placeholder = getPlaceholder(parameterSelect: parameterSelect, selectedOption: selectedOption)
        let keyboardType = getKeyboardType(parameterSelect: parameterSelect)
        let limit = getLimit(parameterSelect: parameterSelect)
        
        return TextFieldFactory.makeTextField(
            text: nil,
            placeholderText: placeholder,
            keyboardType: keyboardType,
            limit: limit
        )
    }
    
    static func getPlaceholder(parameterSelect: Payments.ParameterSelect, selectedOption: Payments.ParameterSelect.Option?) -> String {
        
        selectedOption?.name ?? parameterSelect.placeholder
    }
    
    static func getKeyboardType(parameterSelect: Payments.ParameterSelect) -> KeyboardType {
        
        (parameterSelect.id == Payments.Parameter.Identifier.requisitsKpp.rawValue) ? .number : .default
    }
    
    static func getLimit(parameterSelect: Payments.ParameterSelect) -> Int? {
        
        (parameterSelect.id == Payments.Parameter.Identifier.requisitsKpp.rawValue) ? 9 : nil
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
                SelectedOptionView(viewModel: selectedOptionViewModel, isChevronEnabled: viewModel.isEditable, namespace: namespace) {
                    
                    if viewModel.isEditable {
                        
                        viewModel.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
                    }
                }

            case let .list(optionsListViewModel):
                OptionsListView(viewModel: optionsListViewModel, namespace: namespace) {
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
                    
                } selected: { optionId in
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected(optionId: optionId))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

//MARK: - Internal Views

extension PaymentsSelectView {
    
    struct SelectedOptionView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.SelectedOptionViewModel
        let isChevronEnabled: Bool
        let namespace: Namespace.ID
        let toggle: () -> Void
        
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
                        .lineLimit(1)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if isChevronEnabled {
                    
                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                        .padding(.top, 10)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle() }
        }
    }
    
    struct OptionsListView: View {
    
        @ObservedObject var viewModel: PaymentsSelectView.ViewModel.OptionsListViewModel
        let namespace: Namespace.ID
        let toggle: () -> Void
        let selected: (PaymentsSelectView.ViewModel.OptionViewModel.ID) -> Void
        
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
                            .accessibilityIdentifier("ParameterSelectTitle")
                        
                        RegularTextFieldView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16), backgroundColor: Color.clear, tintColor: .textSecondary, textColor: .textSecondary)
                            .accessibilityIdentifier("ParameterSelectFilterInputText")
                            .disabled(viewModel.isDisabledTF(viewModel.title))
                    }
                    
                    Spacer()
                    
                    if viewModel.selected != nil {

                        Button(action: toggle) {
                            
                            Image.ic24ChevronUp
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(.iconGray)
                                .frame(width: 24, height: 24)
                                .padding(.top, 10)
                        }
                    }
                }
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.filtered) { optionViewModel in
                            
                            PaymentsSelectView.OptionView(viewModel: optionViewModel, isSelected: optionViewModel.id == viewModel.selected) {
                                selected(optionViewModel.id)
                            }
                            
                            if optionViewModel.id != viewModel.filtered.last?.id {
                                
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
        let select: () -> Void

        var body: some View {
            
            VStack {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    PaymentsSelectView.OptionIconView(viewModel: viewModel.icon, isSelected: isSelected)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.name)
                            .font(.textH4M16240())
                            .foregroundColor(.textSecondary)
                            .lineLimit(3)
                            .accessibilityIdentifier("SelectOptionDescription")
                        
                        if let subname = viewModel.subname {
                            
                            Text(subname)
                                .font(.textH4R16240())
                                .foregroundColor(.textPlaceholder)
                        }
                        
                        if let workingTime = viewModel.timeWork {
                            
                            Text(workingTime)
                                .font(.textH4R16240())
                                .foregroundColor(.mainColorsBlack)
                        }
                        
                        if let currencies = viewModel.currencies {
                            
                            HStack {
                                
                                ForEach(currencies) { currency in
                                    
                                    PaymentsSelectView.CurrencyView(viewModel: currency)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { select() }
        }
    }
    
    struct OptionIconView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.OptionViewModel.IconViewModel
        let isSelected: Bool
        
        var body: some View {
            
            switch viewModel {
            case .circle:
                PaymentsSelectView.RadioIconView(isSelected: isSelected)
                
            case let .image(image):
                image
                    .resizable()
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    //TODO: extract to global scope and merge with RadioIconView from PaymentSelectDropDownView
    struct RadioIconView: View {
        
        let isSelected: Bool
        
        var body: some View {
            
            //TODO: load icons from StyleGuide
            
            if isSelected {
                
                Image("Payments Icon Circle Selected")
                    .frame(width: 24, height: 24)
                    .accessibilityIdentifier("PaymentsIconCircleSelected")
            } else {
                
                Image("Payments Icon Circle Empty")
                    .frame(width: 24, height: 24)
                    .accessibilityIdentifier("PaymentsIconCircleEmpty")
                    
            }
        }
    }
    
    struct CurrencyView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.OptionViewModel.Currency
        
        var body: some View {
            
            HStack {
                
                viewModel.icon
                    .frame(width: 12, height: 12)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.currency)
                    .foregroundColor(.mainColorsGray)
                    .font(.textH4R16240())
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: PaymentsGroupViewModel) -> some View {
        PaymentsGroupView(viewModel: viewModel)
    }

    static var previews: some View {
        
        Group {
            
            preview(PaymentsSelectView.ViewModel.emptySelectionGroup)
                .previewDisplayName("Empty Selection")
            
            preview(PaymentsSelectView.ViewModel.selectedGroup)
                .previewDisplayName("Selected")
            
            preview(PaymentsSelectView.ViewModel.disabledGroup)
                .previewDisplayName("Disabled")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectView.ViewModel {
    
    static let emptySelectionGroup = PaymentsGroupViewModel(items: [
        
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
                    .init(id: "2", name: "Длинный, очень длинный текст для отладки анимации при выборе данной опции"),
                    .init(id: "3", name: "(FGJB) UNITED BANK EGYPT - ALEXANDRIA (WABOUR AL MAYA)", subname: "ALEXANDRIA, 2 Hanou St., Wabour Al Maya", timeWork: "Working clock: 12:30 - 13:30", currencies: ["USD", "EUR"], icon: .circle)
                ]))
    ])
    
    static let selectedGroup = PaymentsGroupViewModel(items: [
        
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
    
    static let disabledGroup = PaymentsGroupViewModel(items: [
        PaymentsSelectView.ViewModel.selectedDisabled
    ])
    
    
    static let selectedDisabled: PaymentsSelectView.ViewModel = {
        
        let viewModel = PaymentsSelectView.ViewModel(
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
        viewModel.updateEditable(update: .value(false))
        
        return viewModel
        
    }()
    
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
