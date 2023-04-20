//
//  PaymentSelectBankViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 08.12.2022.
//

import SwiftUI
import Combine
import TextFieldRegularComponent

//MARK: - ViewModel

extension PaymentsSelectBankView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {

        @Published var state: State

        private let model: Model
        fileprivate static let defaultIcon: Image = .ic24Bank

        init(state: PaymentsSelectBankView.ViewModel.State, source: PaymentsParameterRepresentable, model: Model) {
            
            self.state = state
            self.model = model
            super.init(source: source)
        }
    
        convenience init(with parameterSelect: Payments.ParameterSelectBank, model: Model) throws {
            
            guard parameterSelect.options.isEmpty == false else {
                throw Payments.Error.ui(.selectBankMissingOptions(parameterSelect.id))
            }
            
            if let selectedOptionId = parameterSelect.value,
               parameterSelect.options.map(\.id).contains(selectedOptionId) == false {
                throw Payments.Error.ui(.selectBankIncorrectOptionSelected(parameterSelect.id))
            }
            
            self.init(
                state: .collapsed(
                    .init(
                        value: parameterSelect.value,
                        parameter: parameterSelect,
                        defaultIcon: Self.defaultIcon)),
                source: parameterSelect,
                model: model)
            
            bind()
        }
        
        override var isValid: Bool { value.current != nil }
    }
}

//MARK: - Computed properties

extension PaymentsSelectBankView.ViewModel {
    
    private var parameterSelectBank: Payments.ParameterSelectBank? { source as? Payments.ParameterSelectBank }
}

//MARK: Bindings

extension PaymentsSelectBankView.ViewModel {
    
    private func bind() {
        
        Publishers
            .CombineLatest(
                action.compactMap( { $0 as? PaymentsParameterViewModelAction.SelectBank.List.Toggle } ),
                $isEditable.removeDuplicates()
            )
            .map(\.1)
            .filter({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelectBank = parameterSelectBank else {
                    return
                }
                
                switch state {
                case .collapsed:
                    withAnimation {
                        state = .expanded(ExpandedViewModel(with: value.current, parameter: parameterSelectBank, defaultIcon: Self.defaultIcon))
                    }
                    
                case .expanded:
                    withAnimation {
                        state = .collapsed(CollapsedViewModel(value: value.current, parameter: parameterSelectBank, defaultIcon: Self.defaultIcon))
                    }
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap( { $0 as? PaymentsParameterViewModelAction.SelectBank.List.BankItemTapped } )
            .map(\.id)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] bankItemId in
                
                update(value: bankItemId)
                
                guard let parameterSelectBank = parameterSelectBank else {
                    return
                }
                
                withAnimation {
                    state = .collapsed(CollapsedViewModel(value: value.current, parameter: parameterSelectBank, defaultIcon: Self.defaultIcon))
                }
                
            }.store(in: &bindings)
        
        
        action
            .compactMap({ $0 as? PaymentsParameterViewModelAction.SelectBank.List.SelectAllTapped })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelectBank = self.parameterSelectBank,
                      let selectAllOption = parameterSelectBank.selectAll else {
                    return
                }

                //TODO: move ContactsViewModel initialization to PaymentsOperationViewModel.
                let contactsViewModel: ContactsViewModel = {
                    
                    switch selectAllOption.type {
                    case .banks: return .init(model, mode: .select(.banks))
                    case .banksFullInfo: return .init(model, mode: .select(.banksFullInfo))
                    }
                    
                }()
                
                bind(contactsViewModel: contactsViewModel)
                action.send(PaymentsParameterViewModelAction.SelectBank.ContactSelector.Show(viewModel: contactsViewModel))
                
            }.store(in: &bindings)
        
        $isEditable
            .dropFirst()
            .removeDuplicates()
            .filter({ !$0 })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelectBank = parameterSelectBank else {
                    return
                }
  
                withAnimation {
                    state = .collapsed(CollapsedViewModel(value: value.current, parameter: parameterSelectBank, defaultIcon: Self.defaultIcon))
                }
              
            }.store(in: &bindings)
    }
}

extension PaymentsSelectBankView.ViewModel {
    
    private func bind(contactsViewModel: ContactsViewModel) {
            
            contactsViewModel.action
                .compactMap({$0 as? ContactsViewModelAction.BankSelected })
                .map(\.bankId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] bankId in
                    
                    guard let self = self else { return }
                    
                    guard let parameterSelectBank = self.parameterSelectBank,
                          let option = parameterSelectBank.options.first(where: { $0.id == bankId } ) else {
                        return
                    }
                    
                    update(value: option.id)
                    
                    withAnimation {
                        self.state = .collapsed(.init(value: self.value.current, parameter: parameterSelectBank, defaultIcon: Self.defaultIcon))
                    }
                    
                    self.action.send(PaymentsParameterViewModelAction.SelectBank.ContactSelector.Close())
   
                }.store(in: &bindings)
        }

}

//MARK: - Types

extension PaymentsSelectBankView.ViewModel {
    
    enum State {
        
        case collapsed(CollapsedViewModel)
        case expanded(ExpandedViewModel)
    }
    
    struct CollapsedViewModel {

        let icon: IconViewModel
        let title: TitleViewModel
        
        enum TitleViewModel: Equatable {
            
            case selected(title: String, name: String)
            case empty(title: String)
        }
    }
    
    class ExpandedViewModel: ObservableObject {

        @Published var icon: IconViewModel
        let title: String
        let textField: TextFieldRegularView.ViewModel
        @Published var list: ListState
        
        private let selectAll: SelectAllItemViewModel?
        private let banksList: [BankItemViewModel]
        
        var bindings = Set<AnyCancellable>()
        
        init(icon: IconViewModel, title: String, textField: TextFieldRegularView.ViewModel, list: ListState, selectAll: SelectAllItemViewModel?, banksList: [BankItemViewModel]) {
            
            self.icon = icon
            self.title = title
            self.textField = textField
            self.list = list
            self.selectAll = selectAll
            self.banksList = banksList
        }
        
        enum ListState: Equatable {
            
            case filterred(selectAll: SelectAllItemViewModel?, banks: [BankItemViewModel])
            case empty(EmptyListViewModel)
        }
    }
        
    struct SelectAllItemViewModel: Equatable {
        
        let icon: Image
        let name: String
    }
        
    struct BankItemViewModel: Identifiable, Equatable {
        
        let id: String
        let icon: IconViewModel
        let name: String
        let subtitle: String?
        
        let searchValue: String
    }
    
    struct EmptyListViewModel: Equatable {
        
        var icon: Image = .ic24Search
        var title: String = "Не удалось найти банк"
    }
    
    enum IconViewModel: Equatable {
        
        case icon(Image)
        case image(Image)
    }
}

//MARK: - Convenience inits

extension PaymentsSelectBankView.ViewModel.CollapsedViewModel {
    
    init(value: Payments.Parameter.Value, parameter: Payments.ParameterSelectBank, defaultIcon: Image) {
        
        if let option = parameter.options.first(where: { $0.id == value }) {
            
            //TODO: more elegant solution required
            if let subtitle = option.subtitle {
                
                // bank BIC
                self.init(icon: .init(with: option, defaultIcon: defaultIcon), title: .selected(title: parameter.title, name: subtitle))
                
            } else {
                
                // bank name
                self.init(icon: .init(with: option, defaultIcon: defaultIcon), title: .selected(title: parameter.title, name: option.name))
            }
            
        } else {
            
            self.init(icon: .icon(defaultIcon), title: .empty(title: parameter.title))
        }
    }
}

extension PaymentsSelectBankView.ViewModel.ExpandedViewModel {
    
    convenience init(with value: Payments.Parameter.Value, parameter: Payments.ParameterSelectBank, defaultIcon: Image) {
        
        let icon: PaymentsSelectBankView.ViewModel.IconViewModel = {
           
            guard let option = parameter.options.first(where: { $0.id == value }) else {
                return .icon(defaultIcon)
            }
            
            return .init(with: option, defaultIcon: defaultIcon)
        }()
        
        let placeholder: String = {
            
            guard let option = parameter.options.first(where: { $0.id == value }) else {
                return parameter.placeholder
            }
            
            //TODO: more elegant solution required
            if let subtitle = option.subtitle {
                
                // bank bic
                return subtitle
                
            } else {
                
                // bank name
                return option.name
            }
            
        }()
        
        let banksList = parameter.options.map { option in
        
            return PaymentsSelectBankView.ViewModel.BankItemViewModel(
                id: option.id,
                icon: .init(with: option, defaultIcon: defaultIcon),
                name: option.name,
                subtitle: option.subtitle,
                searchValue: option.searchValue)
        }
        
        let selectAllOption = PaymentsSelectBankView.ViewModel.SelectAllItemViewModel(parameter: parameter)
        
        self.init(icon: icon,
                  title: parameter.title,
                  textField: .init(placeholder: placeholder,
                                   keyboardType: parameter.keyboardType.keyboardStyle),
                  list: .filterred(selectAll: selectAllOption, banks: banksList),
                  selectAll: selectAllOption,
                  banksList: banksList)
        
        bind()
    }
    
    private func bind() {
        
        textField.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case let .focus(text: text, cursorPosition: _):
                    update(with: text)
                    
                case let .noFocus(text):
                    update(with: text)
                    
                case .placeholder:
                    update(with: "")
                }
                
            }.store(in: &bindings)
    }
    
    func update(with searchText: String) {
        
        switch searchText {
        case "":
            withAnimation {
                list = .filterred(selectAll: selectAll, banks: banksList)
            }
            
        default:
            
            let filterredBanks = banksList.filter {
                $0.searchValue.lowercased().contained(in: [searchText.lowercased()])
            }
            
            if filterredBanks.isEmpty {
                
                withAnimation {
                    list = .empty(.init())
                }
                
            } else {
                
                withAnimation {
                    list = .filterred(selectAll: selectAll, banks: filterredBanks)
                }
            }
        }
    }
}

extension PaymentsSelectBankView.ViewModel.SelectAllItemViewModel {
 
    init?(parameter: Payments.ParameterSelectBank) {
        
        guard let selectAllOption = parameter.selectAll else {
            return nil
        }
        
        self.init(icon: Image(selectAllOption.iconName), name: selectAllOption.title)
    }
}

extension Payments.ParameterSelectBank.KeyboardType {
    
    var keyboardStyle: TextFieldRegularView.ViewModel.KeyboardType {
        
        switch self {
        case .normal: return .default
        case .number: return .number
        }
    }
}

extension PaymentsSelectBankView.ViewModel.IconViewModel {
    
    init(with option: Payments.ParameterSelectBank.Option, defaultIcon: Image) {
        
        switch option.icon?.image {
        case let .some(image):
            self = .image(image)
            
        case .none:
            self = .icon(defaultIcon)
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum SelectBank {
        
        enum List {
            
            struct Toggle: Action {}
            
            struct SelectAllTapped: Action {}
            
            struct BankItemTapped: Action {
                
                let id: PaymentsSelectBankView.ViewModel.BankItemViewModel.ID
            }
        }
        
        enum ContactSelector {
            
            struct Show: Action {
                
                let viewModel: ContactsViewModel
            }
            
            struct Close: Action {}
        }
    }
}

//MARK: - View

struct PaymentsSelectBankView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Namespace var namespace
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.state {
            case let .collapsed(collapsedViewModel):
                CollapsedStateView(viewModel: collapsedViewModel, isChevronEnabled: viewModel.isEditable, namespace: namespace) {
                    
                    if viewModel.isEditable {
                        
                        viewModel.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 13)
                
            case let .expanded(expandedViewModel):
                ExpandedView(viewModel: expandedViewModel, namespace: namespace) {
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())
                    
                } selectAll: {
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.SelectBank.List.SelectAllTapped())
                    
                } selected: { bankItemId in
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.SelectBank.List.BankItemTapped(id: bankItemId))
                }
            }
        }
    }
    
    struct CollapsedStateView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.CollapsedViewModel
        let isChevronEnabled: Bool
        let namespace: Namespace.ID
        let toggle: () -> Void
        
        var body: some View {
            
            HStack(spacing: 12) {
                
                IconView(viewModel: viewModel.icon)
                    .frame(width: 32, height: 32)
                
                titleView()
                
                Spacer()
                
                if isChevronEnabled {
                    
                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                }
            }
            .matchedGeometryEffect(id: MatchedID.selected, in: namespace)
            .contentShape(Rectangle())
            .onTapGesture { toggle() }
        }
        
        @ViewBuilder
        func titleView() -> some View {
            
            switch viewModel.title {
            case let .selected(title: title, name: name):
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                    
                    Text(name)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                }
            
            case let .empty(title: title):
                Text(title)
                    .font(.textH4M16240())
                    .foregroundColor(.textPlaceholder)
            }
        }
    }
    
    struct ExpandedView: View {
        
        @ObservedObject var viewModel: PaymentsSelectBankView.ViewModel.ExpandedViewModel
        let namespace: Namespace.ID
        let toggle: () -> Void
        let selectAll: () -> Void
        let selected: (PaymentsSelectBankView.ViewModel.BankItemViewModel.ID) -> Void
        
        var body: some View {
            
            VStack {
                
                HStack(spacing: 12) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                        
                        TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16, weight: .medium), textColor: .textSecondary)
                            .frame(height: 24)
                    }
  
                    Spacer()
                    
                    Button(action: toggle) {
                        
                        Image.ic24ChevronUp
                            .renderingMode(.template)
                            .foregroundColor(.iconGray)
                    }
                }
                .matchedGeometryEffect(id: MatchedID.selected, in: namespace)
                .padding(.horizontal, 12)
                .padding(.top, 13)
                
                switch viewModel.list {
                case let .filterred(selectAll: selectAllItemViewModel, banks: banks):
                   
                    ScrollView(.horizontal, showsIndicators: false) {

                        LazyHStack(alignment: .top, spacing: 8) {
                            
                            if let selectAllItemViewModel {
                                
                                SelectAllItemView(viewModel: selectAllItemViewModel, tapped: selectAll)
                                    .padding(.bottom, 8)
                            }
                            
                            ForEach(banks) { bankItemViewModel in
                                
                                BankItemView(viewModel: bankItemViewModel) {
                                    
                                    selected(bankItemViewModel.id)
                                }
                                .frame(width: 64)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 13)
                    }
                    
                case let .empty(emptyListViewModel):
                    EmptyListView(viewModel: emptyListViewModel)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 13)
                }
            }
        }
    }
    
    struct BankItemView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.BankItemViewModel
        let tapped: () -> Void
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                IconView(viewModel: viewModel.icon)
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 8)
                
                Text(viewModel.name)
                    .font(.textBodyXSR11140())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                if let subtitle = viewModel.subtitle {
                    
                    Text(subtitle)
                        .font(.textBodyXSR11140())
                        .foregroundColor(.textPlaceholder)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { tapped() }
        }
    }
    
    struct SelectAllItemView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.SelectAllItemViewModel
        let tapped: () -> Void
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                Group {
                    
                    viewModel.icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                        .background(Circle().foregroundColor(.white).frame(width: 40, height: 40))
                    
                }.frame(width: 40, height: 40)
                
                Text(viewModel.name)
                    .font(.textBodyXSR11140())
                    .foregroundColor(.textSecondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { tapped() }
        }
    }
    
    struct EmptyListView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.EmptyListViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                Color.bordersDivider
                    .cornerRadius(20)
                    .frame(width: 40, height: 40)
                    .overlay(viewModel.icon.resizable().renderingMode(.template).foregroundColor(Color.iconGray).frame(width: 24, height: 24))
                
                Text(viewModel.title)
                    .foregroundColor(.textPlaceholder)
                    .font(.textBodySR12160())
            }
        }
    }
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.IconViewModel
        
        var body: some View {
            
            VStack {
                
                switch viewModel {
                case .image(let image):
                    image
                        .resizable()
                    
                case .icon(let image):
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
    
    enum MatchedID: Hashable {
        
        case selected
    }
}

//MARK: - Preview

struct PaymentsSelectBankView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsGroupView(viewModel: PaymentsSelectBankView.ViewModel.selectedGroup)
            PaymentsGroupView(viewModel: PaymentsSelectBankView.ViewModel.selectedGroupNotEditable)
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectBankView.ViewModel {
    
    static let selectedGroup = PaymentsGroupViewModel(items: [ PaymentsSelectBankView.ViewModel.sampleParameter ])
    
    static let selectedGroupNotEditable = PaymentsGroupViewModel(items: [ PaymentsSelectBankView.ViewModel.sampleParameterNotEditable ])
}

extension PaymentsSelectBankView.ViewModel {
    
    static let sampleParameter = try! PaymentsSelectBankView.ViewModel(
        with: .init(
            .init(id: "bank_param_id", value: nil),
            icon: .init(named: "ic24Bank")!,
            title: "Банк получателя",
            options: [
                .init(id: "0", name: "Сбербанк", subtitle: "04456789", icon: nil, searchValue: "сбербанк"),
                .init(id: "1", name: "Альфабанк", subtitle: "04478998", icon: nil, searchValue: "альфабанк"),
            ],
            placeholder: "Выберите банк",
            selectAll: .init(type: .banks),
            keyboardType: .normal),
        model: .emptyMock)
    
    static let sampleParameterNotEditable: PaymentsSelectBankView.ViewModel = {
        
        let parameter = try! PaymentsSelectBankView.ViewModel(
            with: .init(
                .init(id: "bank_param_id", value: nil),
                icon: .init(named: "ic24Bank")!,
                title: "Банк получателя",
                options: [
                    .init(id: "0", name: "Сбербанк", subtitle: "04456789", icon: nil, searchValue: "сбербанк"),
                    .init(id: "1", name: "Альфабанк", subtitle: "04478998", icon: nil, searchValue: "альфабанк"),
                ],
                placeholder: "Выберите банк",
                selectAll: .init(type: .banks),
                keyboardType: .normal),
            model: .emptyMock)
        parameter.updateEditable(update: .value(false))
        
        return parameter
    }()
}
