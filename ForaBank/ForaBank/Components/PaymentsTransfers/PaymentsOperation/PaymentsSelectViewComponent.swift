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
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var icon: Image
        @Published var title: String
        @Published var content: String?
        @Published var textField: TextFieldRegularView.ViewModel
        @Published var options: [ItemViewModel]?
        let placeholder: String
        var expandAction: () -> Void
        var state: State {
            
            if let content = content, options == nil  {
                return .default(content)
                
            } else if  let _ = content, options != nil {
                return .placeholder
                
            } else {
                return .selected
            }
        }
        
        var parameterSelect: Payments.ParameterSelect? { source as? Payments.ParameterSelect }
        override var isValid: Bool { content != nil }
        private let model: Model
        
        init(icon: Image, title: String, placeholder: String, content: String?, textField: TextFieldRegularView.ViewModel, options: [ItemViewModel]?, model: Model, expandAction: @escaping () -> Void, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.placeholder = placeholder
            self.content = content
            self.textField = textField
            self.options = options
            self.model = model
            self.expandAction = expandAction
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelect, model: Model) {
            
            if let value = parameterSelect.value {
                
                let option = parameterSelect.options.first(where: {$0.id == value})
                self.init(icon: parameterSelect.icon?.image ?? .ic24File, title: parameterSelect.title, placeholder: parameterSelect.placeholder, content: parameterSelect.value, textField: .init(text: option?.name, placeholder: parameterSelect.placeholder, style: .default, limit: nil), options: nil, model: model, expandAction: {}, source: parameterSelect)
            } else {
                
                self.init(icon: parameterSelect.icon?.image ?? .ic24File, title: parameterSelect.title, placeholder: parameterSelect.placeholder, content: parameterSelect.value, textField: .init(text: nil, placeholder: parameterSelect.placeholder, style: .default, limit: nil), options: nil, model: model, expandAction: {}, source: parameterSelect)
            }
            
            self.expandAction = { [weak self] in
                
                self?.action.send(PaymentsParameterViewModelAction.Select.ShowOption())
            }
            
            bind()
            bindTextField(textField: self.textField)
        }
        
        private func bind() {
            
            action
                .compactMap { $0 as? PaymentsParameterViewModelAction.Select.ShowOption}
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    if let options = parameterSelect?.options, self.options == nil {
                        
                        withAnimation {
                            
                            self.textField = .init(text: nil, placeholder: content == nil ? placeholder : content, style: .default, limit: nil)
                            bindTextField(textField: self.textField)
                            
                            self.options = Self.reduce(options: options, icon: .circle) { itemId in
                                
                                self.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId))
                            }
                        }
                    } else {
                        
                        withAnimation {
                            
                            self.options = nil
                        }
                    }
                    
                }.store(in: &bindings)
            
            action
                .compactMap { $0 as? PaymentsParameterViewModelAction.Select.DidSelected}
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] payload in
                    
                    update(value: payload.itemId)
                    
                    guard let item = options?.first(where: { $0.id == payload.itemId }) else {
                        return
                    }
                    
                    options?.first(where: { $0.id == payload.itemId })?.isSelected = true
                    
                    withAnimation {
                        
                        self.content = parameterSelect?.title
                        
                        self.textField.text = item.name
                        
                        if parameterSelect?.icon == nil {
                            
                            switch item.icon {
                            case .circle:
                                break
                                
                            case let .image(image):
                                self.icon = image
                            }
                        }
                    }
                    
                    withAnimation {
                        
                        self.options = nil
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bindTextField(textField: TextFieldRegularView.ViewModel) {
            
            textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    self.content = text
                    
                    guard let options = parameterSelect?.options, self.options != nil else {
                        return
                    }
                    
                    if let text = text, text != "" {
                        
                        self.options = Self.reduce(options: options, icon: .circle, filter: text, action: { itemId in
                            
                            self.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId))
                        })
                        
                    } else {
                        
                        self.options = Self.reduce(options: options, icon: .circle) { itemId in
                            
                            self.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId))
                        }
                    }
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension PaymentsSelectView.ViewModel {
    
    class ItemViewModel: Identifiable {
        
        let id: String
        let icon: IconViewModel
        let name: String
        let subname: String?
        let timeWork: String?
        let currencies: [Currency]?
        @Published var isSelected: Bool
        let action: (String) -> Void
        
        init(id: String, icon: IconViewModel, name: String, subname: String? = nil, timeWork: String?, currencies: [Currency]?, isSelected: Bool, action: @escaping (String) -> Void) {
            
            self.id = id
            self.icon = icon
            self.name = name
            self.subname = subname
            self.timeWork = timeWork
            self.currencies = currencies
            self.isSelected = isSelected
            self.action = action
        }
        
        convenience init(option: Payments.ParameterSelect.Option, icon: IconViewModel, action: @escaping (String) -> Void) {
            
            if let iconImage = option.icon?.image {
                
                self.init(id: option.id, icon: .image(iconImage), name: option.name, subname: option.subname, timeWork: option.timeWork, currencies: nil, isSelected: false, action: action)
                
            } else {
                
                if let curriency = option.currency?.components(separatedBy: ";").dropLast() {
                    var curr: [Currency] = []
                    
                    for currency in curriency {
                        
                        curr.append(Currency.init(icon: .ic12Coins, currency: currency))
                    }
                    
                    self.init(id: option.id, icon: .circle, name: option.name, subname: option.subname, timeWork: option.timeWork, currencies: curr, isSelected: false, action: action)
                    
                } else {
                    
                    self.init(id: option.id, icon: .circle, name: option.name, subname: option.subname, timeWork: option.timeWork, currencies: nil, isSelected: false, action: action)
                }
            }
        }
        
        struct Currency: Identifiable {
            
            let id = UUID()
            let icon: Image
            let currency: String
        }
    }
    
    enum State {
        
        case `default`(String)
        case placeholder
        case selected
    }
    
    enum IconViewModel {
        
        case image(Image)
        case circle
    }
}

//MARK: - Reducers

extension PaymentsSelectView.ViewModel {
    
    static func reduce(options: [Payments.ParameterSelect.Option], icon: IconViewModel, filter: String? = nil, action: @escaping (String) -> Void) -> [ItemViewModel] {
        
        var filterOptions: [ItemViewModel] = []
        
        if let filter = filter {
            
            for option in options {
                
                if option.name.lowercased().contained(in: [filter.lowercased()]) {
                    
                    filterOptions.append(ItemViewModel(option: option, icon: icon, action: action))
                }
            }
            
        } else {
            
            let items = options.map { ItemViewModel(option: $0, icon: icon, action: action)}
            filterOptions = items
        }
        
        return filterOptions
    }
}


//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Select {
        
        struct ShowOption: Action {}
        
        struct SelectedItemDidTapped: Action {}
        
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
            
            HStack(spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                
                VStack(spacing: 4) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodyMR14180())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    switch viewModel.state {
                    case let .default(content):
                        Text(content)
                            .foregroundColor(.textSecondary)
                            .font(.textH4M16240())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    case .placeholder:
                        TextFieldRegularView(viewModel: viewModel.textField, font: UIFont.systemFont(ofSize: 16), backgroundColor: Color.clear, textColor: .textSecondary, tintColor: .textSecondary)
                            .padding(.top, -5)
                        
                    case .selected:
                        TextFieldRegularView(viewModel: viewModel.textField, font: UIFont.systemFont(ofSize: 16), backgroundColor: Color.clear, textColor: .textSecondary, tintColor: .textSecondary)
                            .padding(.top, -5)
                        
                    }
                }
                
                Spacer()
                
                Button(action: { viewModel.expandAction() }) {
                    
                    Image.ic24ChevronUp
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.iconGray)
                        .rotationEffect(viewModel.options != nil ? .degrees(0) : .degrees(180))
                    
                }
            }
            
            if let options = viewModel.options {
                
                VStack {
                    
                    ScrollView(.vertical) {
                        
                        VStack(spacing: 8) {
                            
                            ForEach(options) { item in
                                
                                ItemView(viewModel: item)
                            }
                        }
                    }
                }
                .frame(height: 320)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
    }
    
    struct ItemView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                VStack {
                    
                    HStack(alignment: .top, spacing: 18) {
                        
                        VStack {
                            
                            switch viewModel.icon {
                            case .circle:
                                
                                if viewModel.isSelected {
                                    
                                    Image("Payments Icon Circle Selected")
                                        .frame(width: 24, height: 24)
                                } else {
                                    
                                    Image("Payments Icon Circle Empty")
                                        .frame(width: 24, height: 24)
                                    
                                }
                                
                            case let .image(image):
                                
                                image
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 5)
                        
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
                    
                    HStack(spacing: 18) {
                        
                        Color.clear
                            .frame(width: 24, height: 24)
                        
                        VStack {
                            
                            Divider()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }.buttonStyle(PushButtonStyle())
        }
    }
}

//MARK: - Preview

struct PaymentsSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSelectView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsSelectView(viewModel: .sampleContent)
                .previewLayout(.fixed(width: 375, height: 120))
            
            PaymentsSelectView(viewModel: .sampleOptions)
                .previewLayout(.fixed(width: 375, height: 180))
            
            PaymentsSelectView(viewModel: .notSelectedParameter)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsSelectView(viewModel: .selectedParameter)
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectView.ViewModel {
    
    //MARK: viewModel state
    
    static var sample: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        
        var viewModel = PaymentsSelectView.ViewModel(icon: .ic24File, title: "Тип услуги", placeholder: "Начните ввод для поиска", content: nil, textField: .init(text: nil, placeholder: "placeholder", style: .default, limit: nil), options: nil, model: .emptyMock, expandAction: {})
        
        return viewModel
    }()
    
    static var sampleContent: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        
        var viewModel = PaymentsSelectView.ViewModel(icon: .ic24File, title: "Тип услуги", placeholder: "Начните ввод для поиска", content: "Транспортный налог", textField: .init(text: nil, placeholder: "placeholder", style: .default, limit: nil), options: nil, model: .emptyMock, expandAction: {})
        
        return viewModel
    }()
    
    static var sampleOptions: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        
        var viewModel = PaymentsSelectView.ViewModel(icon: .ic24File, title: "Тип услуги", placeholder: "Начните ввод для поиска", content: "Транспортный налог", textField: .init(text: nil, placeholder: "Начните ввод для поиска", style: .default, limit: nil), options: [ItemViewModel.init(id: "1", icon: .circle, name: "Имущественный налог", timeWork: nil, currencies: nil, isSelected: false, action: {_ in })], model: .emptyMock, expandAction: {})
        
        return viewModel
    }()
    
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect.init(Payments.Parameter.init(id: "", value: nil), title: "Тип услуги", placeholder: "Начните ввод для поиска", options: [])
        
        let viewModel = try! PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
        
        return PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
    }()
    
    static var selectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(Payments.Parameter.init(id: "", value: "Имущественный налог"), title: "Тип услуги", placeholder: "Начните ввод для поиска", options: [])
        
        var viewModel = try! PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
        
        return viewModel
    }()
}
