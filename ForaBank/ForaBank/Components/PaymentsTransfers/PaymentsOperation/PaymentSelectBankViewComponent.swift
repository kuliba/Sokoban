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
        override var isValid: Bool { model.dictionaryFullBankInfoList()?.contains(where: {$0.bic == selectedItem.textField.text}) == true && parameterSelect?.validator.isValid(value: value.current) ?? false }
        
        init(_ model: Model, selectedItem: SelectedItemViewModel, list: ListViewModel?, warning: String? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.model = model
            self.selectedItem = selectedItem
            self.list = list
            self.warning = warning
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelectBank, model: Model) throws {
            
            let selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: nil, placeholder: parameterSelect.title, style: .number, limit: 9, regExp: "^[0-9]\\d*$"), action: {})
            
            self.init(model, selectedItem: selectedItem, list: nil, source: parameterSelect)
            
            self.selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: parameterSelect.value, placeholder: parameterSelect.title, style: .number, limit: 9, regExp: "^[0-9]\\d*$"), action: { [weak self] in
                self?.action.send(PaymentsSelectBankViewModelAction.ShowBanksList())
            })
            
            bind()
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
                
                update(value: content)
                
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
                        
                        self.list?.filteredItems = options
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        self.selectedItem.title = value.current != nil || selectedItem.textField.isEditing.value == true ? parameterSelect?.title : nil
                    }
                }
                
                guard let content = selectedItem.textField.text,
                      let banks = model.dictionaryFullBankInfoList() else {
                    return
                }
                
                if let bank = banks.first(where: {$0.bic == content}),
                   let image = bank.svgImage.image {
                    
                    self.selectedItem.icon = .image(image)
                    self.selectedItem.title = parameterSelect?.title
                    
                } else {
                    
                    self.selectedItem.icon = .placeholder
                    self.selectedItem.title = parameterSelect?.title
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

                        self.list = nil
                        self.selectedItem.title = (selectedItem.textField.text != nil && selectedItem.textField.text != "") ? parameterSelect?.title : nil
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
                    
                    guard list == nil else {
                        
                        withAnimation {
                            
                            self.list = nil
                        }
                        return
                    }
                    
                    guard let banks = self.model.dictionaryFullBankInfoList() else {
                        return
                    }
                    
                    var options: [ListViewModel.ItemViewModel] = Self.reduce(model, banksData: banks) {{ itemId in
                        
                        self.action.send(PaymentsSelectBankViewModelAction.DidSelectBank(id: itemId))
                    }}
                    
                    options.insert(ListViewModel.ItemViewModel(id: UUID().uuidString, icon: .icon(Image.ic24MoreHorizontal), name: "Смотреть все", subtitle: nil, lineLimit: 2, action: { [weak self] _ in
                        
                        guard let model = self?.model else {
                            return
                        }
                        
                        let contactViewModel = ContactsViewModel(model, mode: .select(.banksFullInfo))
                        self?.bind(contactsViewModel: contactViewModel)
                        self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
                    }), at: 0)
                    
                    let listViewModel = ListViewModel(items: options, filteredItems: options)
                    
                    withAnimation {
                        
                        self.list = listViewModel
                    }
                    
                case let payload as PaymentsSelectBankViewModelAction.DidSelectBank:
                    
                    guard let banks = self.list?.items,
                          let bank = banks.first(where: {$0.id == payload.id}),
                          let bic = bank.subtitle else{
                        return
                    }
                    
                    switch bank.icon {
                    case .image(let image):
                        withAnimation {
                            
                            self.selectedItem.icon = .image(image)
                            self.selectedItem.textField.text = bic
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
                    self?.selectedItem.textField.text = bank?.bic
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
        
        var textField: TextFieldRegularView.ViewModel
        var title: String?
        let action: () -> Void
        @Published var icon: IconViewModel

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, icon: IconViewModel, textField: TextFieldRegularView.ViewModel, title: String? = nil, action: @escaping () -> Void) {
            
            self.model = model
            self.icon = icon
            self.textField = textField
            self.title = title
            self.action = action
        }
        
        enum IconViewModel {
            
            case placeholder
            case image(Image)
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
            
            if let banksViewModel = viewModel.list {
                
                BanksListView(viewModel: banksViewModel)
            }
        }
    }
    
    struct BanksListView: View {
        
        @ObservedObject var viewModel: ViewModel.ListViewModel
        
        var body: some View {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(alignment: .top, spacing: 4) {
                    
                    ForEach(viewModel.filteredItems) { item in
                        
                        ItemViewHorizontal(viewModel: item)
                            .frame(width: 70)
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
                        .fill(Color.mainColorsGrayLightest)
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
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                                .padding(.bottom, 4)
                            
                        } else {
                            
                            EmptyView()
                        }
                        
                        HStack {
                            
                            TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 14), textColor: .textSecondary)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            withAnimation {
                                
                                Image.ic24ChevronRight
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.mainColorsGray)
                                    .rotationEffect(isExpanded == true ? .degrees(0) : .degrees(+90))
                                    .onTapGesture {
                                        viewModel.action()
                                    }
                            }
                        }
                        
                        if let warning = warning {
                            
                            VStack(alignment: .leading, spacing: 8) {
                 
                                Divider()
                                    .frame(height: 1)
                                    .background(Color.systemColorError)
                                
                                Text(warning)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.systemColorError)
                                
                            }.padding(.top, 12)
                            
                        } else {
                            
                            Divider()
                                .frame(height: 1)
                                .background(Color.bordersDivider)
                                .opacity(isEditable ? 1.0 : 0.2)
                                .padding(.top, 12)
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

extension PaymentsSelectBankView.SelectedItemView {
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectBankView.ViewModel.SelectedItemViewModel.IconViewModel
        
        var body: some View {
            
            VStack {
                
                switch viewModel {
                case .image(let image):
                    image
                        .resizable()
                        .renderingMode(.original)
                    
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
    
    static let selectedViewModelSample = PaymentsSelectBankView.ViewModel.SelectedItemViewModel(.emptyMock, icon: .placeholder, textField: .init(text: nil, placeholder: "Бик банка получателя", style: .number, limit: 10, regExp: nil), title: "", action: {})
}

