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
        
        let title: String
        @Published var item: Item
        @Published var warning: String?
        let banksList: BanksList
        
        var isExpanded: Bool { banksList.filteredItems == nil }
        
        private let model: Model
        fileprivate static let defaultIcon: Image = .ic24Bank
        
        private var parameterSelectBank: Payments.ParameterSelectBank? { source as? Payments.ParameterSelectBank }
        
        override var isValid: Bool {
            
            switch item.state {
            case .selected: return true
            default: return false
            }
        }
        
        init(title: String, item: PaymentsSelectBankView.ViewModel.Item, banksList: BanksList, warning: String? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString), model: Model = .emptyMock) {
            
            self.title = title
            self.item = item
            self.banksList = banksList
            self.warning = warning
            self.model = model
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelectBank, model: Model) throws {
            
            let options = parameterSelect.options.map( { BanksList.ItemViewModel(id: $0.id, searchValue: $0.searchValue, icon: $0.type == .regular ? .image($0.icon?.image ?? Self.defaultIcon) : .icon(Image.ic24MoreHorizontal), name: $0.name, subtitle: $0.subtitle, type: .init(type: $0.type)) } )
            
            self.init(title: parameterSelect.title, item: .init(icon: Self.defaultIcon, placeholder: parameterSelect.placeholder, state: .`default`), banksList: .init(itemsList: options), source: parameterSelect, model: model)
            
            bind()
            
            if let value = parameterSelect.value {
                
                self.action.send(PaymentsParameterViewModelAction.BankList.DidSelectBank(id: value))
            }
        }
        
        override func updateValidationWarnings() {
            
            switch item.state {
            case let .editing(textField):
                guard let parameterSelect = parameterSelectBank,
                      let action = parameterSelect.validator.action(with: textField.text, for: .post),
                      case .warning(let message) = action else {
                    
                    return
                }
                
                withAnimation {
                    
                    self.warning = message
                }
                
            default:
                break
                
            }
        }
    }
}

//MARK: Bindings

extension PaymentsSelectBankView.ViewModel {
    
    var itemEditing: AnyPublisher<(Bool, String), Never> {
        
        Publishers
            .CombineLatest(
                $item
                    .compactMap(\.textField)
                    .flatMap( { $0.$isEditing } )
                    .compactMap({ $0 }),
                $item
                    .compactMap(\.textField)
                    .flatMap( { $0.$text } )
                    .compactMap({ $0 })
            )
            .map( { ($0.0, $0.1) } )
            .eraseToAnyPublisher()
    }
    
    private func bind() {
        
        itemEditing
            .receive(on: DispatchQueue.main)
            .sink { [unowned self]  isEditing, text in
                
                switch text {
                case "":
                    
                    banksList.applyFilter(listState: .empty)
                    
                default:
                    
                    guard let parameterSelectBank = parameterSelectBank,
                          let items = self.banksList.filteredItems else {
                        return
                    }
                    
                    if let foundItem = Self.itemFound(items: items, filter: text) {
                        
                        update(value: foundItem.id)
                        
                        let icon: Image = {
                            switch foundItem.icon {
                            case let .icon(icon): return icon
                            case let .image(image): return image
                            }
                        }()
                        
                        withAnimation {
                            
                            item = .init(icon: icon, placeholder: parameterSelectBank.placeholder, state: .selected(.init(id: foundItem.id, title: parameterSelectBank.title, icon: .image(icon), name: foundItem.name)))
                        }
                        
                        banksList.applyFilter(listState: .empty)
                        
                    } else {
                        
                        banksList.applyFilter(listState: .search(text))
                    }
                }
                
                self.objectWillChange.send()
                
            }.store(in: &bindings)
        
        action
            .compactMap( { $0 as? PaymentsParameterViewModelAction.BankList.DidTapped } )
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterSelectBank = parameterSelectBank else {
                    return
                }
                
                let state = Item.State.editing(from: item.state, placeholder: parameterSelectBank.placeholder, keyboardType: .init(parameterSelectBank.keyboardType), limit: nil)
                
                withAnimation {
                    
                    item = .init(icon: item.icon, placeholder: item.placeholder, state: state)
                }
                
                banksList.applyFilter(listState: .full)
                
            }.store(in: &bindings)
        
        action
            .compactMap( { $0 as? PaymentsParameterViewModelAction.BankList.BankListArrow.DidTapped } )
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                if banksList.filteredItems == nil {
                    
                    banksList.applyFilter(listState: .full)
                    
                } else {
                    
                    banksList.applyFilter(listState: .empty)
                }
            }
            .store(in: &bindings)
        
        action
            .compactMap( { $0 as? PaymentsParameterViewModelAction.BankList.DidSelectBank } )
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                guard let parameterSelectBank = parameterSelectBank,
                let items = banksList.filteredItems else {
                    return
                }
                
                if let selectedItem = items.first(where: {$0.id == payload.id}) {
                    
                    update(value: selectedItem.id)
                    
                    let icon: Image = {
                        switch selectedItem.icon {
                        case let .icon(icon): return icon
                        case let .image(image): return image
                        }
                    }()
                    
                    withAnimation {
                        
                        item = .init(icon: icon, placeholder: parameterSelectBank.placeholder, state: .selected(.init(id: selectedItem.id, title: parameterSelectBank.title, icon: selectedItem.icon, name: selectedItem.searchValue)))
                    }
                    
                    banksList.applyFilter(listState: .empty)
                }
                
            }.store(in: &bindings)
    }
    
    func bind(contactsViewModel: ContactsViewModel, placeholder: String) {
        
        contactsViewModel.action
            .compactMap({$0 as? ContactsViewModelAction.BankSelected})
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] bank in
                
                guard let parameterSelectBank = self.parameterSelectBank,
                      let item = parameterSelectBank.options.first(where: { $0.id == bank.bankId } ) else {
                    return
                }
                
                self.action.send(PaymentsParameterViewModelAction.BankList.ContactSelector.Close())
                
                withAnimation {
                    
                    let selectedItem: SelectedItemViewModel = .init(id: item.id, title: parameterSelectBank.title, icon: .image(item.icon?.image ?? Self.defaultIcon), name: item.searchValue)
                    self.item = .init(icon: item.icon?.image ?? .ic24Bank, placeholder: placeholder, state: .selected(selectedItem))
                }
                
                banksList.applyFilter(listState: .empty)
                
            }.store(in: &bindings)
    }
    
    func update(warning: String) {
        
        withAnimation {
            
            self.warning = warning
        }
    }
}

private extension TextFieldRegularView.ViewModel.KeyboardType {
    
    init(_ keyboardType: Payments.ParameterSelectBank.KeyboardType) {
        
        switch keyboardType {
        case .normal: self = .default
        case .number: self = .number
        }
    }
}

extension PaymentsSelectBankView.ViewModel {
    
    struct Item {
        
        let icon: Image
        let placeholder: String
        let state: State
        
        var textField: TextFieldRegularView.ViewModel? {
            
            guard case let .editing(textField) = state else {
                return nil
            }
            
            return textField
        }
    }
    
    struct SelectedItemViewModel {
        
        let id: String
        let title: String
        let icon: IconViewModel
        let name: String
    }
    
    class BanksList: ObservableObject {
        
        @Published private(set) var filteredItems: [ItemViewModel]?
        private let itemsList: [ItemViewModel]
        
        let emptyListTitle = "Не удалось найти банк"
        
        init(itemsList: [ItemViewModel]) {
            
            self.itemsList = itemsList
        }
        
        func applyFilter(listState: ListState) {
            
            switch listState {
            case .empty:
                withAnimation {
                    
                    filteredItems = nil
                }
                
            case let .search(filter):
                withAnimation {
                    
                    self.filteredItems = itemsList.filter {
                        
                        $0.searchValue.lowercased().contained(in: [filter.lowercased()])
                    }
                }
                
                
            case .full:
                withAnimation {
                    
                    filteredItems = itemsList
                }
            }
        }
    }
}

extension PaymentsSelectBankView.ViewModel.Item {
    
    enum State {
        
        case `default`
        case editing(TextFieldRegularView.ViewModel)
        case selected(PaymentsSelectBankView.ViewModel.SelectedItemViewModel)
        
        static func editing(from state: State, placeholder: String, keyboardType: TextFieldRegularView.ViewModel.KeyboardType, limit: Int?) -> State {
            
            switch state {
            case .`default`:
                return .editing(.init(text: nil, placeholder: placeholder, keyboardType: keyboardType, limit: limit))
                
            case .editing:
                return state
                
            case .selected:
                return .editing(.init(text: nil, placeholder: placeholder, keyboardType: keyboardType, limit: limit))
            }
        }
    }
}

extension PaymentsSelectBankView.ViewModel.BanksList {
    
    struct ItemViewModel: Identifiable {
        
        let id: String
        let searchValue: String
        let icon:  PaymentsSelectBankView.ViewModel.IconViewModel
        let name: String
        let subtitle: String?
        let type: Kind
        let lineLimit: Int = 1
        
        enum Kind {
            
            case regular
            case selectAll
            
            init(type: Payments.ParameterSelectBank.Option.Kind) {
                
                switch type {
                    
                case .regular:
                    self = .regular
                    
                case .selectAll:
                    self = .selectAll
                }
            }
        }
    }
    
    enum ListState {
        
        case full
        case search(String)
        case empty
    }
}

extension PaymentsSelectBankView.ViewModel {
    
    enum IconViewModel {
        
        case icon(Image)
        case image(Image)
    }
}

//MARK: - Reducers

extension PaymentsSelectBankView.ViewModel {
    
    static func itemFound(items: [BanksList.ItemViewModel], filter: String) -> BanksList.ItemViewModel? {
        
        let filter = filter.lowercased()
        let filtered = items.filter { $0.searchValue.lowercased().contained(in: [filter]) }
        
        if let item = filtered.first,
           filter == item.searchValue.lowercased() {
            
            return item
            
        } else {
            
            return nil
        }
    }
    
    static func itemFoundById(items: [BanksList.ItemViewModel], id: String) -> BanksList.ItemViewModel? {
        
        items.first(where: { $0.id == id } )
    }
    
    func itemTapped(id: BanksList.ItemViewModel.ID, type: BanksList.ItemViewModel.Kind) {
        
        switch type {
            
        case .regular:
            self.action.send(PaymentsParameterViewModelAction.BankList.DidSelectBank(id: id))
            
        case .selectAll:
            
            guard let parameterSelectBank = self.parameterSelectBank else {
                return
            }
            
            switch parameterSelectBank.transferType {
            case .abroad:
                
                bindContactViewModel(contactViewModel: .init(model, mode: .select(.banksFullInfo)), placeholder: parameterSelectBank.placeholder)
                
            case .sfp:
                
                bindContactViewModel(contactViewModel: .init(model, mode: .select(.banks)), placeholder: parameterSelectBank.placeholder)
                
            case .requisites:
                
                bindContactViewModel(contactViewModel: .init(model, mode: .select(.banksFullInfo)), placeholder: parameterSelectBank.placeholder)
                
            default: break
            }
        }
    }
    
    func bindContactViewModel(contactViewModel: ContactsViewModel, placeholder: String) {
        
        bind(contactsViewModel: contactViewModel, placeholder: placeholder)
        self.action.send(PaymentsParameterViewModelAction.BankList.ContactSelector.Show(viewModel: contactViewModel))
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum SelectBank {
        
        struct ItemDidSelected: Action {
            
            let id: PaymentsSelectBankView.ViewModel.BanksList.ItemViewModel.ID
        }
    }
    
    enum BankList {
        
        enum BankListArrow {
            
            struct DidTapped: Action {}
        }
        
        struct DidSelectBank: Action {
            
            let id: PaymentsSelectBankView.ViewModel.BanksList.ItemViewModel.ID
        }
        
        struct DidTapped: Action {}
        
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
    
    var body: some View {
        
        VStack {
            
            switch viewModel.item.state {
            case .`default`:
                HStack(spacing: 16) {
                    
                    defaultIcon()
                    
                    Text(viewModel.title)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodyMR14180())
                    
                    Spacer()
                    
                    chevronButton()
                }
                .frame(height: 72)
                .padding(.horizontal, 16)
                
            case let .editing(textField):
                HStack(spacing: 16) {
                    
                    Image.ic24Bank
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                    
                    VStack(spacing: 4) {
                        
                        HStack {
                            
                            Text(viewModel.title)
                                .foregroundColor(.textPlaceholder)
                                .font(.textBodyMR14180())
                            
                            Spacer()
                        }
                        
                        TextFieldRegularView(viewModel: textField, font: .systemFont(ofSize: 16, weight: .medium), textColor: .textSecondary)
                            .frame(height: 24)
                    }
                    
                }
                .frame(height: 72)
                .padding(.horizontal, 16)
                
                BanksListView(viewModel: viewModel)
                    .padding(.bottom, 13)
                
            case let .selected(selectedItem):
                SelectedBankView(viewModel: selectedItem, isExpanded: viewModel.isExpanded, isEditable: viewModel.isEditable, warning: viewModel.warning)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 56)
                    .allowsHitTesting(viewModel.isEditable)
            }
        }
        .background(Color.mainColorsGrayLightest)
        .cornerRadius(12)
        .onTapGesture {
            
            viewModel.action.send(PaymentsParameterViewModelAction.BankList.DidTapped())
        }
    }
    
    struct SelectedBankView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.SelectedItemViewModel
        let isExpanded: Bool
        let isEditable: Bool
        let warning: String?
        
        var body: some View {
            
            VStack {
                
                HStack(spacing: 12) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(spacing: 2) {
                        
                        HStack {
                            
                            Text(viewModel.title)
                                .font(.textBodyMR14180())
                                .foregroundColor(.textPlaceholder)
                                .padding(.bottom, 4)
                            
                            Spacer()
                            
                            Image.ic24ChevronRight
                                .foregroundColor(.iconGray)
                                .rotationEffect(isExpanded ? .degrees(90) : .degrees(isExpanded ? -90 : 90))
                                .opacity(isEditable ? 1 : 0.2)
                                .frame(width: 16, height: 16)
                        }
                        
                        HStack {
                            
                            Text(viewModel.name)
                                .font(.textH4M16240())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(height: 72)
                
                if let warning = warning {
                    
                    VStack {
                        
                        Text(warning)
                            .font(.textBodySR12160())
                            .foregroundColor(.systemColorError)
                    }
                }
            }
        }
    }
    
    struct BanksListView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            if let items = viewModel.banksList.filteredItems,
               !items.isEmpty {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(alignment: .top, spacing: 0) {
                        
                        ForEach(items) { item in
                            
                            BankItem(viewModel: item, action: {
                                
                                viewModel.itemTapped(id: item.id, type: item.type)
                            })
                            .frame(width: 64)
                            .padding(.leading, 8)
                        }
                    }
                }
                
            } else {
                
                VStack(spacing: 8) {
                    
                    Color.bordersDivider
                        .cornerRadius(20)
                        .frame(width: 40, height: 40)
                        .overlay(Image.ic24Search.resizable().renderingMode(.template).foregroundColor(Color.iconGray).frame(width: 24, height: 24))
                    
                    Text(viewModel.banksList.emptyListTitle)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodySR12160())
                }
            }
        }
        
        struct BankItem: View {
            
            let viewModel: PaymentsSelectBankView.ViewModel.BanksList.ItemViewModel
            let action: () -> Void
            
            var body: some View {
                
                Button {
                    
                    action()
                    
                } label: {
                    
                    VStack(spacing: 8) {
                        
                        IconView(viewModel: viewModel.icon)
                            .frame(width: 40, height: 40)
                        
                        Text(viewModel.name)
                            .font(.textBodyXSR11140())
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(viewModel.lineLimit)
                        
                        if let subtitle = viewModel.subtitle {
                            
                            Text(subtitle)
                                .font(.textBodyXSR11140())
                                .foregroundColor(.textPlaceholder)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                            
                        }
                    }
                    
                }.buttonStyle(PushButtonStyle())
            }
        }
        
        struct IconView: View {
            
            let viewModel: ViewModel.IconViewModel
            
            var body: some View {
                
                switch viewModel {
                case .image(let image):
                    image
                        .resizable()
                        .renderingMode(.original)
                    
                case .icon(let icon):
                    Circle()
                        .fill(Color.white)
                        .overlay(icon.resizable().renderingMode(.template).frame(width: 24, height: 24))
                }
            }
        }
    }
    
    //MARK: View Builder's
    
    @ViewBuilder
    private func chevronButton() -> some View {
        
        let rotation: Angle = viewModel.isExpanded ? .degrees(90) : .degrees(viewModel.isExpanded ? -90 : 90)
        let opacity = viewModel.isEditable ? 1 : 0.2
        
        Image.ic24ChevronRight
            .foregroundColor(.iconGray)
            .rotationEffect(rotation)
            .opacity(opacity)
            .frame(width: 16, height: 16)
    }
    
    @ViewBuilder
    private func defaultIcon() -> some View {
        
        viewModel.item.icon
            .resizable()
            .foregroundColor(.iconGray)
            .frame(width: 24, height: 24)
    }
}

extension PaymentsSelectBankView.SelectedBankView {
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.IconViewModel
        
        var body: some View {
            
            VStack {
                
                switch viewModel {
                case .image(let image):
                    image
                        .resizable()
                        .frame(width: 32, height: 32)
                    
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
}

//MARK: - Preview

struct PaymentsSelectBankView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            //MARK: Views
            
            PaymentsSelectBankView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Select Bank Components Empty State")
                .padding(20)
            
            PaymentsSelectBankView(viewModel: .sampleFocus)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Select Bank Components Focus State")
                .padding(20)
            
            PaymentsSelectBankView(viewModel: .sampleSelected)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Select Bank Components Selected State")
                .padding(20)
            
            PaymentsSelectBankView(viewModel: .sampleItems)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Select Bank Components With Items")
                .padding(20)
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectBankView.ViewModel {
    
    //Empty State
    static let sample = PaymentsSelectBankView.ViewModel(title: "Банк получателя", item: .init(icon: .ic24Bank, placeholder: "Выберите банк", state: .`default`), banksList: .init(itemsList: []))
    
    
    //Focus State
    static let sampleFocus = PaymentsSelectBankView.ViewModel(title: "Банк получателя", item: .init(icon: .ic24Bank, placeholder: "Выберите банк", state: .editing(.init(text: nil, placeholder: "Выберите банк", keyboardType: .number, limit: nil))), banksList: .init(itemsList: []))
    
    //Selected State
    static let sampleSelected = PaymentsSelectBankView.ViewModel(title: "Банк получателя", item: .init(icon: .ic24Bank, placeholder: "Выберите банк", state: .selected(.selectedItem)), banksList: .init(itemsList: []))
    
    //With Items
    static let sampleItems = PaymentsSelectBankView.ViewModel(title: "Банк получателя", item: .init(icon: .ic24Bank, placeholder: "Выберите банк", state: .editing(.init(text: nil, placeholder: "Выберите банк", keyboardType: .number, limit: nil))), banksList: .init(itemsList: itemsListSample))
    
    static let itemsListSample: [PaymentsSelectBankView.ViewModel.BanksList.ItemViewModel] = [.init(id: UUID().description, searchValue: "searchValue", icon: .icon(.ic24MoreHorizontal), name: "См. все", subtitle: nil, type: .selectAll ), .init(id: UUID().description, searchValue: "searchValue", icon: .image(.init("ID Bank")), name: "ID Bank", subtitle: nil, type: .regular )]
}

extension PaymentsSelectBankView.ViewModel.SelectedItemViewModel {
    
    static let selectedItem = PaymentsSelectBankView.ViewModel.SelectedItemViewModel(id: UUID().description, title: "Выберите банк получателя", icon: .image(.init("ID Bank")), name: "ID Bank")
}
