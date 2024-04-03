//
//  PaymentSelectBankViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 08.12.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

//MARK: - ViewModel

extension PaymentsSelectBankView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {

        @Published var state: State

        private let model: Model
        fileprivate static let defaultIcon: Image = .ic24Bank
        private let scheduler: AnySchedulerOfDispatchQueue

        init(
            state: PaymentsSelectBankView.ViewModel.State,
            source: PaymentsParameterRepresentable,
            model: Model,
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) {
            self.state = state
            self.model = model
            self.scheduler = scheduler
            super.init(source: source)
        }
    
        convenience init(
            with parameterSelect: Payments.ParameterSelectBank,
            model: Model,
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) throws {
            
            guard !parameterSelect.options.isEmpty else {
                throw Payments.Error.ui(.sourceParameterMissingOptions(parameterSelect.id))
            }
            
            if let selectedOptionId = parameterSelect.value,
               !parameterSelect.options.map(\.id).contains(selectedOptionId) {
                throw Payments.Error.ui(.sourceParameterSelectedOptionInvalid(parameterSelect.id))
            }
            
            self.init(
                state: .collapsed(
                    .init(
                        value: parameterSelect.value,
                        parameter: parameterSelect,
                        defaultIcon: Self.defaultIcon)),
                source: parameterSelect,
                model: model,
                scheduler: scheduler
            )
            
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
            .receive(on: scheduler)
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
            .receive(on: scheduler)
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
            .receive(on: scheduler)
            .sink { [unowned self] _ in
                
                guard let parameterSelectBank = self.parameterSelectBank,
                      let selectAllOption = parameterSelectBank.selectAll else {
                    return
                }
                
                action.send(PaymentsParameterViewModelAction.SelectBank.ContactSelector.Show(type: selectAllOption.type))
                
            }.store(in: &bindings)
        
        model.action
            .compactMap { $0 as? ModelAction.LatestPayments.BanksList.Response }
            .receive(on: scheduler)
            .map(\.result)
            .sink { [unowned self] result in
                
                selectDefaultBank(result)
                
            }.store(in: &bindings)
        
        $isEditable
            .dropFirst()
            .removeDuplicates()
            .filter({ !$0 })
            .receive(on: scheduler)
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

    func selectDefaultBank(
        _ result: Result<[PaymentPhoneData], Error>
    ) {
        switch result {
        case let .success(paymentsPhone):
            let defaultBank = paymentsPhone.first { $0.defaultBank == true }
            
            bankItemTapped(
                paymentsPhone: paymentsPhone,
                defaultBank: defaultBank
            )
            
        case .failure:
            break
        }
    }
    
    private func bankItemTapped(
        paymentsPhone: [PaymentPhoneData],
        defaultBank: PaymentPhoneData?
    ) {
        if let defaultBank {
            
            let bankValue = self.parameterSelectBank?.options.first { $0.id == defaultBank.bankId }
            if let bankId = bankValue?.id {
                
                self.action.send(PaymentsParameterViewModelAction.SelectBank.List.BankItemTapped(
                    id: bankId
                ))
            }
            
        } else {
            
            if let bankId = paymentsPhone.first?.bankId {
                
                self.action.send(PaymentsParameterViewModelAction.SelectBank.List.BankItemTapped(
                    id: bankId
                ))
            }
        }
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
        
        @Published private(set) var icon: IconViewModel
        let title: String
        let textField: RegularFieldViewModel
        @Published private(set) var list: ListState
        
        private let selectAll: SelectAllItemViewModel?
        private let banksList: [BankItemViewModel]
        private let scheduler: AnySchedulerOfDispatchQueue
        
        var bindings = Set<AnyCancellable>()
        
        init(
            icon: IconViewModel,
            title: String,
            textField: RegularFieldViewModel,
            list: ListState,
            selectAll: SelectAllItemViewModel?,
            banksList: [BankItemViewModel],
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) {
            self.icon = icon
            self.title = title
            self.textField = textField
            self.list = list
            self.selectAll = selectAll
            self.banksList = banksList
            self.scheduler = scheduler
        }
        
        enum ListState: Equatable {
            
            case filtered(selectAll: SelectAllItemViewModel?, banks: [BankItemViewModel])
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
    
    convenience init(
        with value: Payments.Parameter.Value,
        parameter: Payments.ParameterSelectBank,
        defaultIcon: Image,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
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
        
        let textField = TextFieldFactory.makeTextField(
            text: nil,
            placeholderText: placeholder,
            keyboardType: parameter.keyboardType.keyboardStyle,
            limit: nil,
            scheduler: scheduler
        )
        
        self.init(
            icon: icon,
            title: parameter.title,
            textField: textField,
            list: .filtered(selectAll: selectAllOption, banks: banksList),
            selectAll: selectAllOption,
            banksList: banksList,
            scheduler: scheduler
        )
        
        bind()
    }
    
    private func bind() {
        
        textField.$state
            .map(\.text)
            .receive(on: scheduler)
            .sink { [unowned self] text in
                
                withAnimation {
                    
                    list = update(with: text)
                }
            }
            .store(in: &bindings)
    }
    
    func update(with searchText: String?) -> ListState {
        
        if let searchText, !searchText.isEmpty {
            
            let filteredBanks = banksList.filtered(with: searchText, keyPath: \.searchValue)
            
            return filteredBanks.isEmpty
            ? .empty(.init())
            : .filtered(selectAll: selectAll, banks: filteredBanks)
            
        } else {
            
            return .filtered(selectAll: selectAll, banks: banksList)
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
    
    var keyboardStyle: KeyboardType {
        
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
                
                let type: Payments.ParameterSelectBank.SelectAllOption.Kind
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
                .padding(.leading, 12)
                .padding(.trailing, 16)
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
                    .accessibilityIdentifier("SelectBankIcon")
                
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
                        .accessibilityIdentifier("SelectBankTitleSelected")
                    
                    Text(name)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("SelectBankNameSelected")
                }
            
            case let .empty(title: title):
                Text(title)
                    .font(.textBodyMR14180())
                    .foregroundColor(.textPlaceholder)
                    .accessibilityIdentifier("SelectBankTitle")
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
            
            VStack(spacing: 13) {
                
                HStack(spacing: 12) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                            .accessibilityIdentifier("SelectBankTitleExpanded")
                        
                        RegularTextFieldView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16, weight: .medium), textColor: .textSecondary)
                            .frame(height: 24)
                            .accessibilityIdentifier("SelectBankItemTextFieldExpanded")
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
                case let .filtered(selectAll: selectAllItemViewModel, banks: banks):
                   
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
                    .accessibilityIdentifier("SelectBankItemBankIcon")
                
                Text(viewModel.name)
                    .font(.textBodyXsR11140())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .accessibilityIdentifier("SelectBankItemBankTitle")
                
                if let subtitle = viewModel.subtitle {
                    
                    Text(subtitle)
                        .font(.textBodyXsR11140())
                        .foregroundColor(.textPlaceholder)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .accessibilityIdentifier("SelectBankItemBankSubtitle")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { tapped() }
            .accessibilityIdentifier("SelectBankItemBank")
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
                    .font(.textBodyXsR11140())
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
                case let .image(image):
                    image
                        .resizable()
                        .accessibilityIdentifier("SelectBankIconImage")
                    
                case let .icon(image):
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                        .accessibilityIdentifier("SelectBankIcon")
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
