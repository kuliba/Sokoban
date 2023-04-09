//
//  PaymentSelectBankViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 08.12.2022.
//

import SwiftUI
import Combine
import Shimmer

//MARK: - ViewModel

extension PaymentsSelectBankView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var selectedItem: SelectedItemViewModel
        @Published var list: ListViewModel?
        @Published var warning: String?
        
        var isExpanded: Bool { list == nil }
        
        let model: Model
        
        var parameterSelect: Payments.ParameterSelectBank? { source as? Payments.ParameterSelectBank }
        override var isValid: Bool {
            switch parameterSelect?.transferType {
            case .sfp:
               return model.bankList.value.contains(where: {$0.memberNameRus == selectedItem.textField.text})
                
            case .abroad:
                guard let options = parameterSelect?.options,
                      options.contains(where: {$0.name == selectedItem.textField.text}) else {
                    return false
                }
                
                return true
                            
            default:
                return model.dictionaryFullBankInfoList()?.contains(where: {$0.bic == selectedItem.textField.text}) == true && parameterSelect?.validator.isValid(value: value.current) ?? false
            }
        }
        
        init(_ model: Model, selectedItem: SelectedItemViewModel, list: ListViewModel?, warning: String? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.model = model
            self.selectedItem = selectedItem
            self.list = list
            self.warning = warning
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelectBank, model: Model) throws {
            
            switch parameterSelect.transferType {
            case .abroad:
                let selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: nil, placeholder: parameterSelect.title, style: .number, limit: 9, regExp: nil), collapseAction: {})
                
                self.init(model, selectedItem: selectedItem, list: nil, source: parameterSelect)
                
                if let value = parameterSelect.value, let option = parameterSelect.options.first(where: {$0.id == value}) {
                    
                    self.selectedItem = SelectedItemViewModel(model, icon: .image(option.icon.image ?? .ic24Bank), textField: .init(text: option.name, placeholder: parameterSelect.title, style: .number, limit: nil, regExp: nil), collapseAction: { [weak self] in
                        self?.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
                    })
                    
                } else {
                    
                    self.selectedItem = SelectedItemViewModel(model, icon: .icon(.ic24Bank), textField: .init(text: parameterSelect.value, placeholder: parameterSelect.title, style: .number, limit: nil, regExp: nil), collapseAction: { [weak self] in
                        self?.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
                    })
                }
                
                let list = parameterSelect.options.map({ListViewModel.ItemViewModel(id: $0.id, icon: .image(Image.init(data: $0.icon.data) ?? .ic24Bank), name: $0.name, subtitle: nil) { itemId in
                    
                    self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                }})
                
                self.list = .init(items: list, filteredItems: list)
                
                bind()
            
            case .sfp:
                
                let selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: nil, placeholder: parameterSelect.title, style: .default, limit: nil, regExp: nil), collapseAction: {})
                
                self.init(model, selectedItem: selectedItem, list: nil, source: parameterSelect)
                
                if let bank = model.bankList.value.first(where: {$0.memberId == parameterSelect.value}) {
                   
                    let selectedItem = SelectedItemViewModel(model, icon: .image(bank.svgImage.image ?? .ic24Bank), textField: .init(text: bank.memberNameRus, placeholder: parameterSelect.title, style: .default, limit: nil, regExp: nil), title: parameterSelect.title, collapseAction: { [weak self] in
                        
                        self?.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
                    })
                    
                    self.selectedItem = selectedItem
                }
                
                bind()
                
            default:
                let selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: nil, placeholder: parameterSelect.title, style: .number, limit: 9, regExp: "^[0-9]\\d*$"), collapseAction: {})
                
                self.init(model, selectedItem: selectedItem, list: nil, source: parameterSelect)
                
                self.selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: parameterSelect.value, placeholder: parameterSelect.title, style: .number, limit: 9, regExp: "^[0-9]\\d*$"), collapseAction: { [weak self] in
                    self?.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
                })
                
                bind()
            }
        }
        
        override func updateValidationWarnings() {
            
            if isValid == false,
               let parameterSelect = parameterSelect,
               let action = parameterSelect.validator.action(with: value.current, for: .post),
               case .warning(let message) = action {
                
                withAnimation {
                    
                    self.warning = message
                }
            }
        }
    }
}

//MARK: Bindings

extension PaymentsSelectBankView.ViewModel {
    
    private func bind() {
        
        selectedItem.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] content in
                
                switch self.parameterSelect?.transferType {
                case .requisites:
                    guard let content = selectedItem.textField.text,
                          let banks = model.dictionaryFullBankInfoList() else {
                        return
                    }
                    
                    let items = Self.reduce(model, banksData: banks, filter: content, action: {{ itemId in
                        
                        self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                    }})
                    
                    if items.count > 1 {
                        
                        self.list = .init(items: items, filteredItems: items)
                    }
                    
                    if let bank = banks.first(where: {$0.bic == content}),
                       let image = bank.svgImage.image {
                        
                        self.selectedItem.icon = .image(image)
                        self.selectedItem.title = parameterSelect?.title
                        
                    } else {
                        
                        self.selectedItem.icon = .placeholder
                        self.selectedItem.title = parameterSelect?.title
                    }
                case .abroad:
                   
                    guard let banks = self.list?.items,
                          let bank = banks.first(where: {$0.name == content}) else{
                        return
                    }
                    
                    update(value: bank.id)
                    
                    guard let content = content else {
                        return
                    }
                    
                    if let list = self.list {
                        
                        let options: [ListViewModel.ItemViewModel] = list.items.filter({ item in
                            
                            guard let subtitle = item.subtitle else {
                                return false
                            }
                            
                            if subtitle.contained(in: [content]) {
                                return true
                            }
                            
                            return false
                        })
                        
                        withAnimation {
                            
                            if options.count > 0 {
                                
                                self.list?.filteredItems = options

                            } else {
                                
                                self.list = nil
                            }
                        }
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            
                            self.selectedItem.title = value.current != nil || selectedItem.textField.isEditing.value == true ? parameterSelect?.title : nil
                        }
                    }
                default:
                    break
                }
            }.store(in: &bindings)
        
        selectedItem.textField.isEditing
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isEditing in
                
                if isEditing == true {
                    
                    withAnimation {
                        
                        self.selectedItem.title = parameterSelect?.title
                        self.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
                        self.warning = nil
                    }
                    
                } else {
                    
                    withAnimation(.easeIn(duration: 0.2)) {

                        self.selectedItem.title = nil
                    }
                    
                    if let parameterSelect = parameterSelect,
                       let action = parameterSelect.validator.action(with: value.current, for: .post),
                       case .warning(let message) = action {
                        
                        withAnimation {
                            
                            self.warning = message
                        }
                        
                    } else {
                        
                        if let banks = self.model.dictionaryFullBankInfoList(),
                           let text = self.selectedItem.textField.text,
                           text.count == parameterSelect?.limitator?.limit,
                           banks.contains(where: {$0.bic == text}) == false {
                            
                            withAnimation {
                                
                                self.warning = "Неверный БИК банка получателя"
                            }
                        } else {
                            
                            withAnimation {
                                
                                self.warning = nil
                            }
                        }
                        
                    }
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as PaymentsSelectBankViewModelAction.ShowBanksList:
                    
                    switch self.parameterSelect?.transferType {
                    case .abroad:
                        if self.list == nil {
                            
                            guard let list = parameterSelect?.options.map({ListViewModel.ItemViewModel(id: $0.id, icon: .image(Image.init(data: $0.icon.data) ?? .ic24Bank), name: $0.name, subtitle: nil) { itemId in

                                self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                            }}) else {
                                return
                            }
                            
                            withAnimation {
                                
                                self.list = .init(items: list, filteredItems: list)
                            }

                        } else {
                            
                            withAnimation {
                                
                                self.list = nil
                            }
                        }
                    case .sfp:
                        if list == nil {
                            
                            withAnimation {
                                
                                var options: [ListViewModel.ItemViewModel] = Self.reduceBankData(model, banksData: model.bankList.value) {{ itemId in
                                    
                                    self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                                }}
                                
                                options.insert(ListViewModel.ItemViewModel(id: UUID().uuidString, icon: .icon(Image.ic24MoreHorizontal), name: "См. все", subtitle: nil, lineLimit: 2, action: { [weak self] _ in
                                    
                                    guard let model = self?.model else {
                                        return
                                    }
                                    
                                    let contactViewModel = ContactsViewModel(model, mode: .select(.banksFullInfo))
                                    self?.bind(contactsViewModel: contactViewModel)
                                    self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
                                }), at: 0)
                                
                                self.list = .init(items: options, filteredItems: options)
                            }
                        } else {
                            
                            withAnimation {
                                
                                self.list = nil
                            }
                        }
                        
                    default:
                        if let items = self.list?.items {
                            
                            withAnimation {
                                
                                self.list?.filteredItems = items
                            }
                        }
                        
                        guard let banks = self.model.dictionaryFullBankInfoList() else {
                            return
                        }
                        
                        var options: [ListViewModel.ItemViewModel] = Self.reduce(model, banksData: banks) {{ itemId in
                            
                            self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                        }}
                        
                        options.insert(ListViewModel.ItemViewModel(id: UUID().uuidString, icon: .icon(Image.ic24MoreHorizontal), name: "См. все", subtitle: nil, lineLimit: 2, action: { [weak self] _ in
                            
                            guard let model = self?.model else {
                                return
                            }
                            
                            let contactViewModel = ContactsViewModel(model, mode: .select(.banksFullInfo))
                            self?.bind(contactsViewModel: contactViewModel)
                            self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
                        }), at: 0)
                        
                        self.list = .init(items: options, filteredItems: options)
                    }
                    
                case let payload as PaymentsSelectBankViewModelAction.DidSelectBank:
                    
                    switch self.parameterSelect?.transferType {
                    case .abroad:
                        guard let banks = self.list?.items,
                              let bank = banks.first(where: {$0.id == payload.id}) else{
                            return
                        }

                        withAnimation {
                            
                            self.selectedItem.id = bank.id
                            self.selectedItem.textField.setText(to: bank.name)
                            self.selectedItem.title = parameterSelect?.title
                        }

                        switch bank.icon {
                        case .image(let image):
                            withAnimation {
                                
                                self.selectedItem.icon = .image(image)
                            }
                        
                        default: break
                        }
                        
                        update(value: bank.id)
                        
                        withAnimation {
                        
                            self.list = nil
                            self.warning = nil
                        }
                    case .requisites:
                    
                        guard let banks = self.list?.items,
                              let bank = banks.first(where: {$0.id == payload.id}),
                              let bic = bank.subtitle else{
                            return
                        }
                        
                        update(value: bic)
                        
                        switch bank.icon {
                        case .image(let image):
                            withAnimation {
                                
                                self.selectedItem.icon = .image(image)
                                self.selectedItem.textField.setText(to: bic)
                                self.selectedItem.title = parameterSelect?.title
                                self.list = nil
                            }
                            
                        default: break
                        }
                        
                        withAnimation {
                            
                            self.warning = nil
                        }
                        
                        withAnimation {
                            
                            self.list = nil
                        }
                        
                    default:
                        
                        guard let banks = self.list?.items,
                              let bank = banks.first(where: {$0.id == payload.id}) else{
                            return
                        }
                        
                        switch bank.icon {
                        case .image(let image):
                            withAnimation {
                                
                                self.selectedItem.title = parameterSelect?.title
                                self.selectedItem.icon = .image(image)
                                self.selectedItem.textField.setText(to: bank.name)
                            }
                            
                        default: break
                        }
                        
                        update(value: bank.id)
                        
                        withAnimation {
                        
                            self.list = nil
                            self.warning = nil
                        }
                    }
                    
                default: break
                }
            }.store(in: &bindings)
    }
    
    func bind(contactsViewModel: ContactsViewModel) {
        
        contactsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                switch action {
                case let payload as ContactsViewModelAction.BankSelected:
                    guard let banks = self?.model.dictionaryFullBankInfoList() else {
                        return
                    }
                    
                    let bank = banks.first(where: {$0.memberId == payload.bankId})
                    self?.selectedItem.textField.setText(to: bank?.bic)
                    self?.list = nil
                    self?.action.send(PaymentsParameterViewModelAction.BankList.ContactSelector.Close())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func update(warning: String) {
        
        withAnimation {
            
            self.warning = warning
        }
    }
}

extension PaymentsSelectBankView.ViewModel {
    
    class SelectedItemViewModel: ObservableObject {

        var id: String?
        var textField: TextFieldRegularView.ViewModel
        @Published var icon: IconViewModel
        @Published var title: String?
        var collapseAction: () -> Void
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, id: String? = nil, icon: IconViewModel, textField: TextFieldRegularView.ViewModel, title: String? = nil, collapseAction: @escaping () -> Void) {
            
            self.model = model
            self.id = id
            self.icon = icon
            self.textField = textField
            self.title = title
            self.collapseAction = collapseAction
        }
        
        enum IconViewModel {
            
            case placeholder
            case image(Image)
            case icon(Image)
        }
    }
    
    class ListViewModel: ObservableObject {
        
        let items: [ItemViewModel]
        @Published var filteredItems: [ItemViewModel]
        
        init(items: [ItemViewModel], filteredItems: [ItemViewModel]) {
            
            self.items = items
            self.filteredItems = filteredItems
        }
        
        struct ItemViewModel: Identifiable {
            
            let id: String
            let icon: IconViewModel
            let name: String
            let subtitle: String?
            var lineLimit: Int = 1
            let action: (String) -> Void
            
            enum IconViewModel {
                
                case icon(Image)
                case image(Image)
            }
        }
    }
}

//MARK: - Reducers

extension PaymentsSelectBankView.ViewModel {
    
    static func reduceAnywayBanks(banks: [AnywayOperatorData], action: @escaping () ->(ListViewModel.ItemViewModel.ID) -> Void) -> [ListViewModel.ItemViewModel] {
        
        var items = [ListViewModel.ItemViewModel]()
        
        for bank in banks {
            
            items.append(ListViewModel.ItemViewModel.init(id: bank.id, icon: .image(.ic12ArrowDown), name: bank.name, subtitle: nil, action: action()))
        }
        
        return items
    }
    
    static func reduceBankData(_ model: Model, banksData: [BankData], filter: String? = nil, action: @escaping () ->(String) -> Void) -> [ListViewModel.ItemViewModel] {
        
        var items = [ListViewModel.ItemViewModel]()
        
        for bank in banksData {
            
            if let bankIcon = bank.svgImage.image {
                
                items.append(ListViewModel.ItemViewModel(id: bank.memberId, icon: .image(bankIcon), name: bank.memberNameRus, subtitle: nil, action: action()))
                
            } else {
                
                items.append(ListViewModel.ItemViewModel(id: bank.memberId, icon: .icon(Image.ic24Bank), name: bank.memberNameRus, subtitle: nil, action: action()))
            }
        }
        
        for id in model.prefferedBanksList.value.reversed() {
            
            guard let bank = banksData.first(where: {$0.memberId == id}) else {
                continue
            }
            
            let name = bank.memberNameRus
            let id = bank.memberId
            
            if let bankIcon = bank.svgImage.image {
                
                items.insert(ListViewModel.ItemViewModel(id: id, icon: .image(bankIcon), name: name, subtitle: nil, action: action()), at: 0)
                
            } else {
                
                items.insert(ListViewModel.ItemViewModel(id: id, icon: .icon(Image.ic24Bank), name: name, subtitle: nil, action: action()), at: 0)
            }
        }
        
        if let filter = filter, filter != "" {
            
            let items = items.filter({$0.name.contained(in: [filter]) == true})
            return items
        }
        
        return items
    }
    
    static func reduce(_ model: Model, banksData: [BankFullInfoData], filter: String? = nil, action: @escaping () ->(String) -> Void) -> [ListViewModel.ItemViewModel] {
        
        var items = [ListViewModel.ItemViewModel]()
        
        for bank in banksData {
            
            guard let name = bank.rusName, let id = bank.memberId else {
                break
            }
            
            if let bankIcon = bank.svgImage.image {
                
                items.append(ListViewModel.ItemViewModel(id: id, icon: .image(bankIcon) ,name: name, subtitle: bank.bic, action: action()))
                
            } else {
                
                items.append(ListViewModel.ItemViewModel(id: id, icon: .icon(Image.ic24Bank), name: name, subtitle: bank.bic, action: action()))
            }
        }
        
        for id in model.prefferedBanksList.value.reversed() {
            
            guard let bank = banksData.first(where: {$0.memberId == id}) else {
                continue
            }
            
            guard let name = bank.rusName, let id = bank.memberId else {
                break
            }
            
            if let bankIcon = bank.svgImage.image {
                
                items = items.filter({$0.subtitle != bank.bic})
                items.insert(ListViewModel.ItemViewModel(id: id, icon: .image(bankIcon), name: name, subtitle: bank.bic, action: action()), at: 0)
                
            } else {
                
                items = items.filter({$0.subtitle != bank.bic})
                items.insert(ListViewModel.ItemViewModel(id: id, icon: .icon(Image.ic24Bank), name: name, subtitle: bank.bic, action: action()), at: 0)
            }
        }
        
        if let filter = filter, filter != "" {
            
            let items = items.filter({$0.subtitle?.contained(in: [filter]) == true})
            return items
        }
        
        return items
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum BankList {
        
        enum ContactSelector {
            
            struct Show: Action {
                
                let viewModel: ContactsViewModel
            }
            
            struct Close: Action {}
        }
    }
}

//MARK: - Action

struct PaymentsSelectBankViewModelAction {
    
    struct DidSelectBank: Action {
        
        let id: PaymentsSelectBankView.ViewModel.ListViewModel.ItemViewModel.ID
    }
    
    struct ShowBanksList: Action {}
    
}

//MARK: - View

struct PaymentsSelectBankView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            SelectedItemView(viewModel: viewModel.selectedItem, isExpanded: viewModel.isExpanded, isEditable: viewModel.isEditable, warning: viewModel.warning)
                .frame(minHeight: 56)
                .allowsHitTesting(viewModel.isEditable)
                .padding(.horizontal, 12)
            
            if let banksViewModel = viewModel.list, viewModel.isExpanded == false {
                
                BanksListView(viewModel: banksViewModel)
            }
        }
        .padding(.vertical, 13)
    }
    
    struct BanksListView: View {
        
        @ObservedObject var viewModel: ViewModel.ListViewModel
        
        var body: some View {
            
            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 0) {

                    Color.clear
                        .frame(width: 4)
                    
                    HStack(alignment: .top, spacing: 0) {
                        
                        ForEach(viewModel.filteredItems) { item in
                            
                            ItemViewHorizontal(viewModel: item)
                                .frame(width: 64)
                                .padding(.trailing, 8)
                        }
                    }
                }
            }
        }
        
        struct ItemViewHorizontal: View {
            
            let viewModel: PaymentsSelectBankView.ViewModel.ListViewModel.ItemViewModel
            
            var body: some View {
                
                Button {
                    
                    viewModel.action(viewModel.id)
                    
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
            
            let viewModel: ViewModel.ListViewModel.ItemViewModel.IconViewModel
            
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
    
    struct SelectedItemView: View {
        
        @ObservedObject var viewModel: PaymentsSelectBankView.ViewModel.SelectedItemViewModel
        let isExpanded: Bool
        let isEditable: Bool
        let warning: String?
        
        var body: some View {
            
            if isEditable == true {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodyMR14180())
                                .foregroundColor(.textPlaceholder)
                                .padding(.bottom, 4)
                            
                        } else {
                            
                            EmptyView()
                        }
                        
                        HStack {
                            
                            TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16))
                                .font(.textH4M16240())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                        }
                        
                        if let warning = warning {
                            
                            VStack {
                                
                                Text(warning)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.systemColorError)
                            }
                        }
                    }
                    
                    withAnimation {
                        
                        Image.ic24ChevronDown
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.mainColorsGray)
                            .rotationEffect(isExpanded == true ? .degrees(0) : .degrees(-180))
                            .onTapGesture {
                                viewModel.collapseAction()
                            }
                    }
                }
                
            } else {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                                .padding(.bottom, 4)
                            
                        } else {
                            
                            EmptyView()
                        }
                        
                        HStack {
                            
                            if let text = viewModel.textField.text {
                                
                                Text(text)
                                    .font(.textBodyMM14200())
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

extension PaymentsSelectBankView.SelectedItemView {
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.SelectedItemViewModel.IconViewModel
        
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
                    
                case .placeholder:
                    Image.ic24FileHash
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.mainColorsGray)
                        .frame(width: 24, height: 24)
                        .padding(.leading, 4)
                    
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectBankView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSelectBankView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            PaymentsSelectBankView(viewModel: .sampleError)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            //MARK: Views
            PaymentsSelectBankView.SelectedItemView(viewModel: .selectedViewModelSample, isExpanded: false, isEditable: false, warning: nil)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected View")
            
            PaymentsSelectBankView.BanksListView(viewModel: .itemsViewModelSample)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Banks List")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectBankView.ViewModel {
    
    static let sample = PaymentsSelectBankView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample)
    
    static let sampleError = PaymentsSelectBankView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample, warning: "Неверный БИК банка получателя")
}

extension PaymentsSelectBankView.ViewModel.ListViewModel {
    
    static let itemsViewModelSample = PaymentsSelectBankView.ViewModel.ListViewModel(items: [.init(id: "", icon: .image(Image.ic64ForaColor), name: "Фора-банк", subtitle: "0445283290", action: {_ in })], filteredItems: [])
}

extension PaymentsSelectBankView.ViewModel.SelectedItemViewModel {
    
    static let selectedViewModelSample = PaymentsSelectBankView.ViewModel.SelectedItemViewModel(.emptyMock, icon: .placeholder, textField: .init(text: nil, placeholder: "Бик банка получателя", style: .number, limit: 10, regExp: nil), title: "", collapseAction: {})
}

