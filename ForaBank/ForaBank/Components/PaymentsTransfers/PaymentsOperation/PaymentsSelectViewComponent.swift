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
        
        private let model: Model

        override var isFullContent: Bool {
            
            switch state {
            case .list(_): return true
            default: return false
            }
        }

        init(state: PaymentsSelectView.ViewModel.State, model: Model, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.state = state
            self.model = model
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelect, model: Model) throws {
            
            self.init(state: .list([]), model: model, source: parameterSelect)
            
            switch parameterSelect.type {
                
            case .general:
                if let selectedOptionId = parameterSelect.parameter.value,
                   let option = parameterSelect.options.first(where: {$0.id == selectedOptionId}) {
                    
                    self.state = .selected(.init(option: option, title: parameterSelect.title, action: { [weak self] in
                        self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped())
                    }))
                    
                } else {
                    
                    let options = reduce(options: parameterSelect.options) { [weak self] in
                        
                        { itemId in self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId)) }
                    }
                    self.state = .list(options)
                }
                
            case .banks:
                guard let selectedOptionId = parameterSelect.parameter.value,
                      let bankData = model.bankList.value.first(where: { $0.id == selectedOptionId }) else {
                    
                    throw Payments.Error.missingValueForParameter(parameterSelect.parameter.id)
                }
                
                let selectedViewModel = SelectedItemViewModel(bankData: bankData, title: parameterSelect.title) { [weak self] in
                    self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped())
                }
                
                self.state = .selected(selectedViewModel)
                
            case .countries:
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
                        guard let item = items?.first(where: { $0.id == payload.itemId }) else {
                            return
                        }
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            
                            switch item.actionType {
                            case .select:
                                guard let parameterSelect = parameterSelect else {
                                    return
                                }
                                let selectedViewModel = SelectedItemViewModel(with: item, title: parameterSelect.title, action: { [weak self] in
                                    self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped())
                                })
                                state = .selected(selectedViewModel)
                                
                            case .banks:
                                let contactsViewModel = ContactsViewModel(model, mode: .select(.banks, ""))
                                bind(contactsViewModel: contactsViewModel)
                                self.action.send(PaymentsParameterViewModelAction.Select.BanksSelector.Show(viewModel: contactsViewModel))
                                
                            case .countries:
                                break
                                //TODO: setup action for open bottom sheet
                            }
                        }
                        
                    case _ as PaymentsParameterViewModelAction.Select.SelectedItemDidTapped:
                        
                        guard let parameterSelect = source as? Payments.ParameterSelect,
                              let selectedViewItem = selectedItem else {
                            return
                        }
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            
                            switch parameterSelect.type {
                            case .general:
                                let options = parameterSelect.options.map{ Option(id: $0.id, name: $0.name)}
                                let popUpViewModel = PaymentsPopUpSelectView.ViewModel(title: selectedViewItem.title, description: nil, options: options, selected: selectedViewItem.id, action: { [weak self] optionId in
                                    
                                    self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: optionId))
                                    self?.action.send(PaymentsParameterViewModelAction.Select.PopUpSelector.Close())
                                })
                                
                                self.action.send(PaymentsParameterViewModelAction.Select.PopUpSelector.Show(viewModel: popUpViewModel))
                                
                            case .banks:
                                guard let parameterValueCallback = parameterValue,
                                    let phone = parameterValueCallback(Payments.Parameter.Identifier.sfpPhone.rawValue) else {
                                    return
                                }
                                let prefferedBanks = model.paymentsByPhone.value[phone.digits]
                                let banksData = model.bankList.value
                                let options = reduce(prefferedBanks: prefferedBanks, banksData: banksData) { [weak self] in
                                    
                                    { itemId in self?.action.send(PaymentsParameterViewModelAction.Select.DidSelected(itemId: itemId)) }

                                }
                                self.state = .unwrapped(selectedViewItem, options)
                                
                            case .countries:
                                //TODO: create countries options
                                break
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
        
        private func bind(contactsViewModel: ContactsViewModel) {
            
            contactsViewModel.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as ContactsViewModelAction.BankSelected:
                        guard let bankData = self?.model.bankList.value.first(where: { $0.id == payload.bankId }),
                              let parameterSelect = self?.parameterSelect else {
                            return
                        }
                        
                        let selectedItem = SelectedItemViewModel(bankData: bankData, title: parameterSelect.title) { [weak self] in
                            self?.action.send(PaymentsParameterViewModelAction.Select.SelectedItemDidTapped())
                        }
                        self?.state = .selected(selectedItem)
                        self?.action.send(PaymentsParameterViewModelAction.Select.BanksSelector.Close())
    
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension PaymentsSelectView.ViewModel {
    
    enum State {
        
        case list([ItemViewModel])
        case selected(SelectedItemViewModel)
        case unwrapped(SelectedItemViewModel, [ItemViewModel])
    }
    
    struct ItemViewModel: Identifiable {
        
        let id: Payments.ParameterSelect.Option.ID
        let icon: IconViewModel
        let name: String
        let actionType: ActionType
        let overlay: Overlay?
        let action: (ItemViewModel.ID) -> Void
        
        init(id: Payments.ParameterSelect.Option.ID = UUID().uuidString, icon: IconViewModel, name: String, actionType: ActionType = .select, overlay: Overlay? = nil, action: @escaping (ItemViewModel.ID) -> Void) {
            
            self.id = id
            self.icon = icon
            self.name = name
            self.actionType = actionType
            self.overlay = overlay
            self.action = action
        }
                
        enum ActionType {
            
            case select
            case banks
            case countries
        }
        
        enum Overlay {
            
            case isFavorite
        }
        
        init(option: Payments.ParameterSelect.Option, action: @escaping (ItemViewModel.ID) -> Void) {
            
            if let iconImage = option.icon.image {
                
                self.init(id: option.id, icon: .image(iconImage), name: option.name, action: action)
 
            } else {
                
                self.init(id: option.id, icon: .placeholder, name: option.name, action: action)
            }
        }
    }
    
    struct SelectedItemViewModel: Identifiable {
        
        let id: Payments.ParameterSelect.Option.ID
        let icon: IconViewModel
        let title: String
        let name: String
        let action: () -> Void
        
        init(id: Payments.ParameterSelect.Option.ID, icon: IconViewModel, title: String, name: String, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.name = name
            self.action = action
        }
        
        init(with item: ItemViewModel, title: String, action: @escaping () -> Void) {
            
            self.init(id: item.id, icon: item.icon, title: title, name: item.name, action: action)
        }
        
        init(option: Payments.ParameterSelect.Option, title: String, action: @escaping () -> Void) {
            
            if let iconImage = option.icon.image {
                
                self.init(id: option.id, icon: .image(iconImage), title: title, name: option.name, action: action)
                
            } else {
                
                self.init(id: option.id, icon: .placeholder, title: title, name: option.name, action: action)
            }
        }
        
        init(bankData: BankData, title: String, action: @escaping () -> Void) {
            
            if let bankIcon = bankData.svgImage.image {
                
                self.init(id: bankData.id, icon: .image(bankIcon), title: title, name: bankData.memberNameRus, action: action)
                
            } else {
                
                self.init(id: bankData.id, icon: .placeholder, title: title, name: bankData.memberNameRus, action: action)
            }
        }
    }
    
    enum IconViewModel {
        
        case placeholder
        case image(Image)
        case circle(Image)
    }
}

//MARK: - Reducers

extension PaymentsSelectView.ViewModel {
    
    func reduce(options: [Payments.ParameterSelect.Option], action: @escaping () -> (ItemViewModel.ID) -> Void) -> [ItemViewModel] {
        
        options.map { ItemViewModel(option: $0, action: action()) }
    }

    func reduce(prefferedBanks: [PaymentPhoneData]?, banksData: [BankData], action: @escaping () ->(ItemViewModel.ID) -> Void) -> [ItemViewModel] {
        
        var items = [ItemViewModel]()
        items.append(.init(id: UUID().uuidString, icon: .circle(.ic24MoreHorizontal), name: "Смотреть все", actionType: .banks, action: action()))
        
        if let prefferedBanks = prefferedBanks {
            
            let banksOptions = prefferedBanks.reduce([ItemViewModel]()) { partialResult, preferedBankData in
                
                guard let bank = banksData.first(where: { $0.memberId == preferedBankData.bankId }) else {
                    return partialResult
                }
                
                var updatedPartialResult = partialResult
                
                if let bankIcon = bank.svgImage.image {
                    
                    updatedPartialResult.append(ItemViewModel(id: bank.id, icon: .image(bankIcon) , name: bank.memberNameRus, overlay: preferedBankData.defaultBank ? .isFavorite : nil, action: action()))
                    
                } else {
                    
                    updatedPartialResult.append(ItemViewModel(id: bank.id, icon: .placeholder , name: bank.memberNameRus, overlay: preferedBankData.defaultBank ? .isFavorite : nil, action: action()))
                }
  
                return updatedPartialResult
            }
            
            items.append(contentsOf: banksOptions)
        }
        
        return items
    }
}

//MARK: - Helpers

extension PaymentsSelectView.ViewModel {
    
    //TODO: real placeholder required
    private static let itemIconPlaceholder = Image("Payments Icon Placeholder")
    
    var parameterSelect: Payments.ParameterSelect? { source as? Payments.ParameterSelect }
    
    var items: [ItemViewModel]? {
        
        switch state {
        case let .list(items): return items
        case let .unwrapped(_, items): return items
        default: return nil
        }
    }
    
    var selectedItem: SelectedItemViewModel? {
        
        guard case .selected(let selectedItem) = state else {
            return nil
        }
        
        return selectedItem
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
        
        enum BanksSelector {
            
            struct Show: Action {
                
                let viewModel: ContactsViewModel
            }
            
            struct Close: Action {}
        }
        
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
                    
                    HStack(alignment: .top, spacing: 4) {
                        
                        ForEach(items) { itemViewModel in
                            
                            ItemViewHorizontal(viewModel: itemViewModel)
                                .frame(width: 70)
                        }
                    }
                }
            }
        }
    }
    
    struct ItemViewVertical: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    Text(viewModel.name)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
                
            }.buttonStyle(PushButtonStyle())
        }
    }
    
    struct ItemViewHorizontal: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                VStack(spacing: 8) {
                    
                    if let overlay = viewModel.overlay {
                        
                        IconView(viewModel: viewModel.icon)
                            .frame(width: 40, height: 40)
                            .overlay(OverlayView(viewModel: overlay).offset(x: 20, y: -8))
                        
                    } else {
                        
                        IconView(viewModel: viewModel.icon)
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(viewModel.name)
                        .font(.textBodyXSR11140())
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                
            }.buttonStyle(PushButtonStyle())
        }
    }
    
    struct SelectedItemView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.SelectedItemViewModel
        let isEditable: Bool
        
        var body: some View {
            
            if isEditable == true {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
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
                    
                    IconView(viewModel: viewModel.icon)
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
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.IconViewModel
        
        var body: some View {
            
            switch viewModel {
            case .placeholder:
                Circle()
                    .fill(Color.mainColorsGrayLightest)
                
            case let .image(image):
                image
                    .resizable()
                    .renderingMode(.original)
                
            case let .circle(icon):
                Circle()
                    .fill(Color.mainColorsGrayLightest)
                    .overlay(icon.resizable().renderingMode(.template).frame(width: 24, height: 24))
            }
        }
    }
    
    struct OverlayView: View {
        
        let viewModel: PaymentsSelectView.ViewModel.ItemViewModel.Overlay
        
        var body: some View {
            
            switch viewModel {
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
            .init(icon: .image(Image("Payments List Sample")), name: "Имущественный налог", action: { _ in }),
            .init(icon: .image(Image("Payments List Sample")), name: "Транспортный налог", action: { _ in }),
            .init(icon: .image(Image("Payments List Sample")), name: "Сбор за пользовние объектами водными биологическими ресурсами", action: { _ in })]), model: .emptyMock)
        
        return viewModel
    }()
    
    static var selectedStateMock: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let option: Payments.ParameterSelect.Option = .init(id: "id", name: "Транспортный налог", icon: icon)
        
        var viewModel = PaymentsSelectView.ViewModel(state: .selected(.init(option: option, title: "Транспортный налог", action: {})), model: .emptyMock)
        
        return viewModel
    }()
    
    static var unwrappedStateMock: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let firstItem = PaymentsSelectView.ViewModel.ItemViewModel(icon: .image(Image("Payments List Sample")), name: "Имущественный налог", action: { _ in })
        
        var viewModel = PaymentsSelectView.ViewModel.init(state: .unwrapped(.init(option: .init(id: "id", name: "Имущественный налог", icon: icon), title: "Имущественный налог", action: {}), [
            firstItem,
            .init(icon: .image(Image("Payments List Sample")), name: "Транспортный налог", action: { _ in }),
            .init(icon: .image(Image("Payments List Sample")), name: "Земельный налог", action: { _ in })]), model: .emptyMock)
        
        return viewModel
    }()
    
    //MARK: Parameter
    
    static var notSelectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect( .init(id: UUID().uuidString, value: nil), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        let viewModel = try! PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
        
        return viewModel
    }()
    
    static var selectedParameter: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)])
        
        var viewModel = try! PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
        
        return viewModel
    }()
    
    static var selectedParameterNotEditable: PaymentsSelectView.ViewModel = {
        
        let icon = ImageData(with: UIImage(named: "Payments List Sample")!)!
        let parameter = Payments.ParameterSelect(.init(id: UUID().uuidString, value: "3"), title: "Категория платежа", options: [.init(id: "1", name: "Имущественный налог", icon: icon), .init(id: "2", name: "Транспортный налог", icon: icon), .init(id: "3", name: "Сбор за пользовние объектами водными биологическими ресурсами", icon: icon)], isEditable: false)
        
        var viewModel = try! PaymentsSelectView.ViewModel(with: parameter, model: .emptyMock)
        
        return viewModel
    }()
}

