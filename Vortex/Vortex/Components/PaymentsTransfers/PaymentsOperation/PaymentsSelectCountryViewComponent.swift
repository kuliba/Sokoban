//
//  PaymentsSelectCountryViewComponent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 13.02.2023.
//

import Foundation
import SwiftUI
import Combine
import TextFieldComponent

// MARK: - ViewModel

extension PaymentsSelectCountryView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var selectedItem: SelectedItemViewModel
        @Published var list: ListViewModel?
        @Published var warning: String?
        
        var isExpanded: Bool { list == nil }
        
        let model: Model
        
        var parameterSelect: Payments.ParameterSelectCountry? {
            source as? Payments.ParameterSelectCountry
        }
        
        override var isValid: Bool {
            model.isValid(countryName: selectedItem.textField.text)
            && parameterSelect.isValid(value: value.current)
        }
        
        private let scheduler: AnySchedulerOfDispatchQueue
        
        init(
            _ model: Model,
            selectedItem: SelectedItemViewModel,
            list: ListViewModel?,
            warning: String? = nil,
            source: PaymentsParameterRepresentable = Payments.ParameterMock(),
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) {
            self.model = model
            self.selectedItem = selectedItem
            self.list = list
            self.warning = warning
            self.scheduler = scheduler
            super.init(source: source)
        }
        
        convenience init(
            with parameterSelect: Payments.ParameterSelectCountry,
            model: Model,
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) throws {
            
            let textField = TextFieldFactory.makeTextField(
                text: nil,
                placeholderText: parameterSelect.title,
                keyboardType: .default,
                limit: nil,
                scheduler: scheduler
            )
            let selectedItem = SelectedItemViewModel(icon: .placeholder, textField: textField, action: {})
            
            self.init(
                model,
                selectedItem: selectedItem,
                list: nil,
                source: parameterSelect,
                scheduler: scheduler
            )
            
            if let country = model.country(for: parameterSelect) {
                
                let image = model.image(forCountry: country) ?? .ic12ArrowDown
                
                let textField = TextFieldFactory.makeTextField(
                    text: country.name.capitalized,
                    placeholderText: parameterSelect.title,
                    keyboardType: .default,
                    limit: nil,
                    scheduler: scheduler
                )
                
                self.selectedItem = SelectedItemViewModel(icon: .image(image), textField: textField, action: { [weak self] in
                    self?.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
                })
            }
            
            let imageIds = model.countriesListWithSevice.value.compactMap(\.md5hash)
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: imageIds))
            
            bind()
        }
        
        override func updateValidationWarnings() {
            
            if !isValid,
               let warning = parameterSelect.warning(forValue: value.current) {
                
                withAnimation {
                    
                    self.warning = warning
                }
            }
        }
    }
}

// MARK: Bindings

extension PaymentsSelectCountryView.ViewModel {
    
    private func bind() {
        
        model.action
            .compactMap { $0 as? ModelAction.Dictionary.DownloadImages.Response }
            .receive(on: scheduler)
            .sink { [unowned self] response in
                
                switch response.result {
                case let .success(data):
                    
                    let countries = model.makeItemViewModels(
                        with: data,
                        action: { [weak self] itemId in
                            
                            self?.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: itemId))
                        }
                    )
                    
                    self.list?.items = countries
                        .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                        .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
                    
                case let .failure(error):
                    print(error) //TODO: send error action
                }
            }
            .store(in: &bindings)
        
        selectedItem.textField.textPublisher()
            .receive(on: scheduler)
            .sink { [unowned self] text in
                
                let country = model.country(withName: text)
                update(value: country?.code)
                
                 withAnimation {
                    
                    self.selectedItem.icon = model.iconForCountry(country)
                    
                    list?.updateFilteredItems(with: text)
                 }
            }.store(in: &bindings)
        
        selectedItem.textField.isEditing()
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [unowned self] isEditing in
                
                let warning = updatedWarning(isEditing: isEditing)
                let title = updatedTitle(isEditing: isEditing)
                
                 withAnimation {
                
                    self.warning = warning
                    self.selectedItem.title = title
                    
                     if isEditing {
                         
                         let list = updatedList()
                         
                         withAnimation {
                             
                             self.list = list
                         }
                         
                     } else {
                        
                        self.list = nil
                        
                    }
                 }
            }
            .store(in: &bindings)
        
        action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as PaymentsSelectCountryViewModelAction.ShowCountriesList:
                    
                    let list = updatedList()
                    
                    withAnimation {
                        
                        self.list = list
                    }
                    
                    
                case let payload as PaymentsSelectCountryViewModelAction.DidSelectCountry:
                    
                    guard let country = model.country(withValue: payload.id, at: \.id)
                    else { return }
                    
                    withAnimation {
                        
                        self.selectedItem.icon = model.iconForCountry(country)
                        self.selectedItem.textField.setText(to: country.name.capitalized)
                        self.list = nil
                        self.warning = nil
                    }
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func bind(contactsViewModel: ContactsViewModel) {
        
        contactsViewModel.action
            .compactMap { $0 as? ContactsViewModelAction.CountrySelected }
            .receive(on: scheduler)
            .sink { [weak self] payload in
                
                self?.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: payload.countryId.description))
                //FIXME: action for country select required
                self?.action.send(PaymentsParameterViewModelAction.SelectBank.ContactSelector.Close())
            }
            .store(in: &bindings)
    }
    
    func update(warning: String) {
        
        withAnimation {
            
            self.warning = warning
        }
    }
    
    func updatedWarning(isEditing: Bool) -> String? {
        
        if isEditing {
            
            return nil
            
        } else {
            
            return parameterSelect.warning(forValue: value.current)
        }
    }
    
    func updatedTitle(isEditing: Bool) -> String? {
        
        return isEditing
        ? parameterSelect?.title
        : selectedItem.textField.hasValue ? parameterSelect?.title : nil
    }
    
    func updatedList() -> ListViewModel? {
        
        let select: () -> (String) -> Void = {{ [weak self] itemId in
            
            self?.action.send(PaymentsSelectCountryViewModelAction.DidSelectCountry(id: itemId))
        }}
        
        let showAll: (String) -> Void = { [weak self] _ in
            
            guard let self else { return }
            
            let contactViewModel = self.model.makeContactsViewModel(forMode: .select(.countries))
            self.bind(contactsViewModel: contactViewModel)
            self.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
        }
        
        return Self.reduce(
            countries: model.countriesListWithSevice.value,
            filter: selectedItem.textField.text,
            iconForCountry: model.iconForCountry(_:),
            select: select,
            showAll: showAll
        )
    }
}

// MARK: View Models

extension PaymentsSelectCountryView.ViewModel {
    
    class SelectedItemViewModel: ObservableObject {
                
        @Published var icon: IconViewModel

        let textField: RegularFieldViewModel
        var title: String?
        let action: () -> Void
        
        init(icon: IconViewModel, textField: RegularFieldViewModel, title: String? = nil, action: @escaping () -> Void) {
            
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
        
        func updateFilteredItems(with text: String?) {
            
            filteredItems = items.filtered(with: text, keyPath: \.name)
        }
    }
}

// MARK: - Helpers

extension Model {
    
    typealias ListItemViewModel = PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel
    typealias SelectedItemViewModel = PaymentsSelectCountryView.ViewModel.SelectedItemViewModel
    
    func makeItemViewModels(
        with data: ([(id: String, imageData: ImageData)]),
        action: @escaping (String) -> Void
    ) -> [ListItemViewModel] {
        
        countriesListWithSevice.value.makeItemViewModels(with: data, action: action)
    }
    
    func isValid(countryName: String?) -> Bool {
        
        countriesListWithSevice.value.contains {
            $0.name.capitalized == countryName?.capitalized
        }
    }
    
    func country(
        for parameterSelect: Payments.ParameterSelectCountry
    ) -> CountryWithServiceData? {
        
        country(withValue: parameterSelect.value, at: \.code)
    }
    
    func country<Value: Equatable>(
        withValue value: Value?,
        at keyPath: KeyPath<CountryWithServiceData, Value>
    )-> CountryWithServiceData? {
        
        countriesListWithSevice.value.first { $0[keyPath: keyPath] == value }
    }
    
    func country(
        withName name: String?
    ) -> CountryWithServiceData? {
        
        countriesListWithSevice.value.first {
            
            $0.name.lowercased() == name?.lowercased()
        }
    }
    
    func iconForCountry(
        _ country: CountryWithServiceData?
    ) -> SelectedItemViewModel.IconViewModel {
        
        if let image = image(forCountry: country) {
            
            return .image(image)
            
        } else {
            
            return .placeholder
        }
    }
    
    func iconForCountry(
        _ country: CountryWithServiceData?
    ) -> ListItemViewModel.IconViewModel {
        
        if let image = image(forCountry: country) {
            
            return .icon(image)
            
        } else {
            
            return .placeholder
        }
    }
    
    func image(
        forCountry country: CountryWithServiceData?
    ) -> Image? {
        
        guard let country,
              let key = country.md5hash,
              let imageData = images.value[key]
        else { return nil }
        
        return imageData.image
    }
}

extension ImageData {
    
    var icon: PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel.IconViewModel {
        
        switch image {
        case .none:
            return .placeholder
            
        case let .some(image):
            return .icon(image)
        }
    }
}

extension Optional where Wrapped == Payments.ParameterSelectCountry {
    
    func isValid(
        value: Payments.Parameter.Value
    ) -> Bool {
        
        switch self {
        case .none:
            return false
            
        case let .some(wrapped):
            return wrapped.isValid(value: value)
        }
    }
    
    func warning(
        forValue value: Payments.Parameter.Value
    ) -> String? {
        
        switch self {
        case .none:
            return nil
            
        case let .some(wrapped):
            return wrapped.warning(forValue: value)
        }
    }
}

extension Payments.ParameterSelectCountry {
    
    func isValid(
        value: Payments.Parameter.Value
    ) -> Bool {
        
        validator.isValid(value: value)
    }
    
    func warning(
        forValue value: Payments.Parameter.Value
    ) -> String? {
        
        guard
            let action = validator.action(with: value, for: .post),
            case let .warning(message) = action
        else { return nil }
        
        return message
    }
}

// MARK: - Reducers

extension PaymentsSelectCountryView.ViewModel {
    
    static func reduce(
        countriesData countries: [CountryWithServiceData],
        iconForCountry: @escaping (CountryWithServiceData?) -> ListViewModel.ItemViewModel.IconViewModel,
        filter: String? = nil,
        action: @escaping () -> (String) -> Void
    ) -> [ListViewModel.ItemViewModel] {
        
        countries
            .map {
                .init(
                    with: $0,
                    icon: iconForCountry($0),
                    action: action
                )
            }
            .filtered(with: filter, keyPath: \.subtitle)
    }
    
    static func reduce(
        countries: [CountryWithServiceData],
        filter: String?,
        iconForCountry: @escaping (CountryWithServiceData?) -> ListViewModel.ItemViewModel.IconViewModel,
        select: @escaping () -> (String) -> Void,
        showAll: @escaping (String) -> Void
    ) -> ListViewModel? {
        
        let itemViewModel = ListViewModel.ItemViewModel.showAllItemViewModel(showAll: showAll)
        
        let itemViewModels = Self.reduce(
            countriesData: countries,
            iconForCountry: iconForCountry,
            action: select
        )
        
        let items = [itemViewModel] + itemViewModels
        
        return .init(
            items: items,
            filteredItems: items.filtered(with: filter, keyPath: \.name)
        )
    }
}

extension PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel {
    
    static func showAllItemViewModel(
        showAll: @escaping (String) -> Void
    ) -> Self {
        
        .init(
            id: UUID().uuidString,
            icon: .overlay(Image.ic24MoreHorizontal),
            name: "См. все",
            subtitle: nil,
            lineLimit: 2,
            action: showAll
        )
    }
}

extension Array where Element == CountryWithServiceData {
    
    typealias ItemViewModel = PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel
    
    func makeItemViewModels(
        with data: ([(id: String, imageData: ImageData)]),
        action: @escaping (String) -> Void
    ) -> [ItemViewModel] {
        
        let data = Dictionary(data, uniquingKeysWith: { a, b in a })

        return compactMap { country in
            
            guard let key = country.md5hash,
                  let imageData = data[key]
            else { return nil }
            
            return .init(
                id: country.id,
                icon: imageData.icon,
                name: country.name.capitalized,
                subtitle: nil,
                action: action
            )
        }
    }
}

extension PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel {
    
    init(
        with country: CountryWithServiceData,
        icon: IconViewModel,
        action: @escaping () -> (String) -> Void
    ) {
        
        self.init(
            id: country.id,
            icon: icon,
            name: country.name.capitalized,
            subtitle: nil,
            action: action()
        )
    }
}

// MARK: - Action

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

// MARK: - Action

struct PaymentsSelectCountryViewModelAction {
    
    struct DidSelectCountry: Action {
        
        let id: PaymentsSelectCountryView.ViewModel.ListViewModel.ItemViewModel.ID
    }
    
    struct ShowCountriesList: Action {}
    
}
// MARK: - View

struct PaymentsSelectCountryView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 13) {
            
            SelectedItemView(viewModel: viewModel.selectedItem, isExpanded: viewModel.isExpanded, isEditable: viewModel.isEditable, warning: viewModel.warning)
                .allowsHitTesting(viewModel.isEditable)
                .padding(.leading, 12)
                .padding(.trailing, 16)
            
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
                            .font(.textBodySR12160())
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(viewModel.lineLimit)
                        
                        if let subtitle = viewModel.subtitle {
                            
                            Text(subtitle)
                                .font(.textBodyXsR11140())
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodyMR14180())
                                .foregroundColor(.textPlaceholder)
                                .frame(height: 18)
                            
                        } else {
                            
                            EmptyView()
                                .frame(height: 18)
                        }
                        
                        HStack {
                            
                            RegularTextFieldView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16), textColor: .textSecondary)
                                .font(.textH4M16240())
                                .foregroundColor(.textSecondary)
                                .frame(height: 24)
                            
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
                    
                    Image.ic24Globe
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                    
                }
            }
        }
    }
}

// MARK: - Preview

struct PaymentsSelectCountryView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSelectCountryView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            PaymentsSelectCountryView(viewModel: .sampleError)
                .previewLayout(.fixed(width: 375, height: 200))
                .previewDisplayName("Parameter Complete State")
            
            // MARK: Views
            PaymentsSelectCountryView.SelectedItemView(viewModel: .selectedViewModelSample, isExpanded: false, isEditable: false, warning: nil)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Selected View")
            
            PaymentsSelectCountryView.CountriesListView(viewModel: .itemsViewModelSample)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Parameter Countries List")
        }
    }
}

// MARK: - Preview Content

extension PaymentsSelectCountryView.ViewModel {
    
    static let sample = PaymentsSelectCountryView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample)
    
    static let sampleError = PaymentsSelectCountryView.ViewModel(.emptyMock, selectedItem: .selectedViewModelSample, list: .itemsViewModelSample, warning: "Неверный БИК банка получателя")
}

extension PaymentsSelectCountryView.ViewModel.ListViewModel {
    
    static let itemsViewModelSample = PaymentsSelectCountryView.ViewModel.ListViewModel(items: [.init(id: "", icon: .icon(Image.ic64VortexColor), name: "ИННОВАЦИИ БИЗНЕСА", subtitle: "0445283290", action: {_ in })], filteredItems: [])
}

extension PaymentsSelectCountryView.ViewModel.SelectedItemViewModel {
    
    static let selectedViewModelSample = PaymentsSelectCountryView.ViewModel.SelectedItemViewModel(icon: .placeholder, textField: sampleTextField, title: "", action: {})
    
    private static let sampleTextField = TextFieldFactory.makeTextField(text: nil, placeholderText: "Бик банка получателя", keyboardType: .number, limit: 10)
}
