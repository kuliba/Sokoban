//
//  PaymentsSelectCountryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.02.2023.
//

import Foundation
import SwiftUI
import Combine
import TextFieldRegularComponent

//MARK: - ViewModel

extension PaymentsSelectCountryView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var selectedItem: SelectedItemViewModel
        @Published var list: ListViewModel?
        @Published var warning: String?
        
        var isExpanded: Bool { list == nil }
        
        let model: Model
        
        var parameterSelect: Payments.ParameterSelectCountry? { source as? Payments.ParameterSelectCountry }
        override var isValid: Bool { model.countriesListWithSevice.value.contains(where: {$0.name.capitalized == selectedItem.textField.text?.capitalized}) == true && parameterSelect?.validator.isValid(value: value.current) ?? false }
        
        init(_ model: Model, selectedItem: SelectedItemViewModel, list: ListViewModel?, warning: String? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.model = model
            self.selectedItem = selectedItem
            self.list = list
            self.warning = warning
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterSelectCountry, model: Model) throws {
            
            let selectedItem = SelectedItemViewModel(model, icon: .placeholder, textField: .init(text: nil, placeholder: parameterSelect.title, keyboardType: .default, limit: nil), action: {})
            
            self.init(model, selectedItem: selectedItem, list: nil, source: parameterSelect)
            
            if let country = model.countriesListWithSevice.value.first(where: {$0.code == parameterSelect.value}) {
                
                let image = model.images.value.filter({$0.key == country.md5hash})
                
                self.selectedItem = SelectedItemViewModel(model, icon: .image(image.values.first?.image ?? .ic12ArrowDown), textField: .init(text: country.name.capitalized, placeholder: parameterSelect.title, keyboardType: .default, limit: nil), action: { [weak self] in
                    self?.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
                })
            }
            
            let imageIds = model.countriesListWithSevice.value.compactMap { $0.md5hash }
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: imageIds))
            
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

extension PaymentsSelectCountryView.ViewModel {
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Dictionary.DownloadImages.Response:
                    switch payload.result {
                    case let .success(data):
                        
                        var countryList: [ListViewModel.ItemViewModel] = []
                        
                        for item in data {
                            
                            for country in self.model.countriesListWithSevice.value {
                                
                                if item.id == country.md5hash {
                                    
                                    if let icon = item.imageData.image {
                                        
                                        countryList.append(.init(id: country.id, icon: .icon(icon), name: country.name.capitalized, subtitle: nil, action: { itemId in
                                            
                                            self.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: itemId))
                                        }))
                                    } else {
                                        countryList.append(.init(id: country.id, icon: .placeholder, name: country.name.capitalized, subtitle: nil, action: { itemId in
                                            
                                            self.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: itemId))
                                        }))
                                    }
                                }
                            }
                        }
                        
                        self.list?.items = countryList.sorted(by: {$0.name.lowercased() < $1.name.lowercased()}).sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
                        
                    case let .failure(error):
                        print(error) //TODO: send error action
                    }
                default:
                    break
                }
            }.store(in: &bindings)
        
        selectedItem.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                if let country = model.countriesListWithSevice.value.first(where: {$0.name.lowercased() == text?.lowercased()}) {
                    
                    update(value: country.code)
                    
                    if let imageData = model.images.value.first(where: {$0.key == country.md5hash}),
                       let image = imageData.value.image {
                        
                        withAnimation {
                            
                            self.selectedItem.icon = .image(image)
                        }
                        
                    } else {
                        
                        withAnimation {
                            
                            self.selectedItem.icon = .placeholder
                        }
                    }
                    
                } else {
                    
                    update(value: nil)
                    
                    withAnimation {
                        
                        self.selectedItem.icon = .placeholder
                    }
                }
                
                list?.updateFilteredItems(with: text)
                
            }.store(in: &bindings)
        
        selectedItem.textField.$isEditing
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isEditing in
                
                if isEditing == true {
                    
                    withAnimation {
                        
                        self.selectedItem.title = parameterSelect?.title
                        self.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
                        self.warning = nil
                    }
                    
                } else {
                    
                    withAnimation(.easeIn(duration: 0.2)) {
                        
                        self.list = nil
                        self.selectedItem.title = selectedItem.textField.hasValue ? parameterSelect?.title : nil
                    }
                    
                    if let parameterSelect = parameterSelect,
                       let action = parameterSelect.validator.action(with: value.current, for: .post),
                       case .warning(let message) = action {
                        
                        withAnimation {
                            
                            self.warning = message
                        }
                        
                    } else {
                        
                        let countries = self.model.countriesListWithSevice.value
                        
                        if let text = self.selectedItem.textField.text,
                           text.count == parameterSelect?.limitator?.limit,
                           countries.contains(where: {$0.name == text}) == false {
                            
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
                    
                case _ as PaymentsSelectCountryViewModelAction.ShowCountriesList:
                    
                    guard list == nil else {
                        
                        withAnimation {
                            
                            self.list = nil
                        }
                        return
                    }
                    
                    let countries = self.model.countriesListWithSevice.value
                    
                    var options: [ListViewModel.ItemViewModel] = Self.reduce(model, countriesData: countries) {{ itemId in
                        
                        self.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: itemId))
                    }}
                    
                    options.insert(ListViewModel.ItemViewModel(id: UUID().uuidString, icon: .overlay(Image.ic24MoreHorizontal), name: "См. все", subtitle: nil, lineLimit: 2, action: { [weak self] _ in
                        
                        guard let model = self?.model else {
                            return
                        }
                        
                        let contactViewModel = ContactsViewModel(model, mode: .select(.countries))
                        self?.bind(contactsViewModel: contactViewModel)
                        self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
                    }), at: 0)
                    
                    let listViewModel = ListViewModel(items: options, filteredItems: options)
                    
                    withAnimation {
                        
                        self.list = listViewModel
                    }
                    
                case let payload as PaymentsSelectCountryViewModelAction.DidSelectCountry:
                    
                    let countries = model.countriesListWithSevice.value
                    
                    guard let country = countries.first(where: {$0.id == payload.id}) else{
                        return
                    }
                    
                    if let imageData = model.images.value.first(where: {$0.key == country.md5hash}),
                       let image = imageData.value.image  {

                        withAnimation {
                            
                            self.selectedItem.icon = .image(image)
                            self.selectedItem.textField.setText(to: country.name.capitalized)
                            self.list = nil

                        }
                        
                    } else {
                        
                        withAnimation {
                         
                            self.selectedItem.icon = .placeholder
                            self.selectedItem.textField.setText(to: country.name.capitalized)
                            self.list = nil
                        }
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
                case let payload as ContactsViewModelAction.CountrySelected:
                    self?.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: payload.countryId.description))
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

extension PaymentsSelectCountryView.ViewModel {
    
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
        
        var items: [ItemViewModel]
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
                case overlay(Image)
                case placeholder
            }
        }
        
        func updateFilteredItems(with value: String?) {
            
            if let value = value?.lowercased(), value != "" {
                
                let updateItems = items.filter({ item in
                    
                    if item.name.lowercased().contained(in: [value]) {
                        return true
                    }
                    
                    return false
                })
                
                withAnimation {
                    
                    filteredItems = updateItems
                }
                
            } else {
                
                withAnimation {
                    
                    filteredItems = items
                }
            }
        }
    }
}

//MARK: - Reducers

extension PaymentsSelectCountryView.ViewModel {
    
    static func reduce(_ model: Model, countriesData: [CountryWithServiceData], filter: String? = nil, action: @escaping () ->(String) -> Void) -> [ListViewModel.ItemViewModel] {
        
        var items = [ListViewModel.ItemViewModel]()
        
        for country in countriesData {
            
            let name = country.name.capitalized
            
            if let imageData = model.images.value.first(where: {$0.key == country.md5hash}), let image = imageData.value.image {
                
                items.append(ListViewModel.ItemViewModel(id: country.id, icon: .icon(image) ,name: name, subtitle: nil, action: action()))
                
            } else {
                
                items.append(ListViewModel.ItemViewModel(id: country.id, icon: .placeholder, name: name, subtitle: nil, action: action()))
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
    
    enum CountryList {
        
        enum ContactSelector {
            
            struct Show: Action {
                
                let viewModel: ContactsViewModel
            }
            
            struct Close: Action {}
        }
    }
}

//MARK: - Action

struct PaymentsSelectCountryViewModelAction {
    
    struct DidSelectCountry: Action {
        
        let id: PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel.ID
    }
    
    struct ShowCountriesList: Action {}
    
}
//MARK: - View

struct PaymentsSelectCountryView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            SelectedItemView(viewModel: viewModel.selectedItem, isExpanded: viewModel.isExpanded, isEditable: viewModel.isEditable, warning: viewModel.warning)
                .allowsHitTesting(viewModel.isEditable)
                .padding(.horizontal, 12)
            
            if let countriesViewModel = viewModel.list {
                
                CountriesListView(viewModel: countriesViewModel)
            }
        }
        .padding(.vertical, 13)
    }
    
    struct CountriesListView: View {
        
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
            
            let viewModel: PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel
            
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
                case .icon(let icon):
                    
                    ZStack {
                     
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                        
                        icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .cornerRadius(20)
                    }
                    
                case .overlay(let icon):
                   
                    ZStack {
                     
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                        
                        icon
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                case .placeholder:
                    Circle()
                        .fill(Color.mainColorsGrayLightest)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
    
    struct SelectedItemView: View {
        
        @ObservedObject var viewModel: PaymentsSelectCountryView.ViewModel.SelectedItemViewModel
        let isExpanded: Bool
        let isEditable: Bool
        let warning: String?
        
        var body: some View {
            
            if isEditable == true {
                
                HStack(spacing: 12) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodyMR14180())
                                .foregroundColor(.textPlaceholder)
                            
                        } else {
                            
                            EmptyView()
                        }
                        
                        HStack {
                            
                            TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16), textColor: .textSecondary)
                                .font(.textH4M16240())
                                .foregroundColor(.textSecondary)
                            
                        }
                        
                        if let warning = warning {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Divider()
                                    .frame(height: 1)
                                    .background(Color.systemColorError)
                                
                                Text(warning)
                                    .font(.textBodyMR14180())
                                    .foregroundColor(.systemColorError)
                                
                            }.padding(.top, 12)
                            
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
                                viewModel.action()
                            }
                    }
                }
                
            } else {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodyMR14180())
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

extension PaymentsSelectCountryView.SelectedItemView {
    
    struct IconView: View {
        
        let viewModel: PaymentsSelectCountryView.ViewModel.SelectedItemViewModel.IconViewModel
        
        var body: some View {
            
            VStack {
                
                switch viewModel {
                case .image(let image):
                    image
                        .resizable()
                        .renderingMode(.original)
                        .cornerRadius(20)
                    
                case .placeholder:
                    
                    Circle()
                        .foregroundColor(.mainColorsGray)
                        .frame(width: 32, height: 32)
                        .padding(.leading, 4)
                    
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectCountryView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSelectCountryView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            PaymentsSelectCountryView(viewModel: .sampleError)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            //MARK: Views
            PaymentsSelectCountryView.SelectedItemView(viewModel: .selectedViewModelSample, isExpanded: false, isEditable: false, warning: nil)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected View")
            
            PaymentsSelectCountryView.CountriesListView(viewModel: .itemsViewModelSample)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Countries List")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectCountryView.ViewModel {
    
    static let sample = PaymentsSelectCountryView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample)
    
    static let sampleError = PaymentsSelectCountryView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample, warning: "Неверный БИК банка получателя")
}

extension PaymentsSelectCountryView.ViewModel.ListViewModel {
    
    static let itemsViewModelSample = PaymentsSelectCountryView.ViewModel.ListViewModel(items: [.init(id: "", icon: .icon(Image.ic64ForaColor), name: "Фора-банк", subtitle: "0445283290", action: {_ in })], filteredItems: [])
}

extension PaymentsSelectCountryView.ViewModel.SelectedItemViewModel {
    
    static let selectedViewModelSample = PaymentsSelectCountryView.ViewModel.SelectedItemViewModel(.emptyMock, icon: .placeholder, textField: .init(text: nil, placeholder: "Бик банка получателя", keyboardType: .number, limit: 10), title: "", action: {})
}

