//
//  LatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 17.10.2022.
//

import SwiftUI
import Combine

extension LatestPaymentsView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var items: [ItemViewModel]
        let isBaseButtons: Bool
        let filter: Filter?
        
        private let model: Model
        private let mode: Mode?
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, mode: Mode? = .regular, items: [LatestPaymentsView.ViewModel.ItemViewModel], isBaseButtons: Bool, filter: Filter?) {
            
            self.model = model
            self.mode = mode
            self.items = items
            self.isBaseButtons = isBaseButtons
            self.filter = filter
        }
        
        convenience init(_ model: Model, mode: Mode? = .regular, isBaseButtons: Bool = true, filter: Filter? = nil) {
            
            self.init(model, mode: mode, items: (0..<4).map { _ in .placeholder(.init()) }, isBaseButtons: isBaseButtons, filter: filter)
            bind()
        }
        
        func bind() {
            
            model.latestPayments
                .combineLatest(model.latestPaymentsUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments, isUpdating in
                    
                    var latestPaymentsFiltered = latestPayments
                    
                    if let filter = filter {
                        
                        switch filter {
                        case let .including(including):
                            latestPaymentsFiltered = latestPayments.filter({ including.contains($0.type) })
                            
                        case let .excluding(excluding):
                            latestPaymentsFiltered = latestPayments.filter({ excluding.contains($0.type) == false })
                        }
                    }
                    
                    var items = Self.itemsReduce(model: model, mode: mode ?? .regular, latest: latestPaymentsFiltered, isUpdating: isUpdating, action: { [weak self] itemId in
                        
                        if let item = latestPayments.first(where: {$0.id == itemId}) {
                            
                            return { self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.LatestPayment(latestPayment: item))}
                        }
                        
                        return {}
                    })
                    
                    if isBaseButtons == true {
                        
                        let templatesButton = Self.createTemplateButton { [weak self] in
                            
                            self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.Templates())
                        }
                        
                        let currencyWalletButton = Self.createCurrencyWalletButton { [weak self] in
                            
                            self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet())
                        }
                        
                        items.insert(contentsOf: [templatesButton, currencyWalletButton], at: 0)
                    }
                    
                    withAnimation {
                        self.items = items
                    }
                    
                }.store(in: &bindings)
        }
        
        static func itemsReduce(model: Model, mode: Mode, latest: [LatestPaymentData], isUpdating: Bool, action: (LatestPaymentData.ID) -> () -> Void) -> [ItemViewModel] {
            
            let latestPaymentsItems = latest.map { item in
                
                ItemViewModel.latestPayment(.init(data: item, model: model, mode: mode, action: action(item.id)))
            }
            
            let updatedItems: [ItemViewModel]
            
            if isUpdating {
                
                if latest.isEmpty {
                    
                    updatedItems = (0..<4).map { _ in .placeholder(.init()) }
                    
                } else {
                    
                    updatedItems = [.placeholder(.init())] + latestPaymentsItems
                }
                
            } else {
                
                updatedItems = latestPaymentsItems
            }
            
            return updatedItems
        }
        
        static func createTemplateButton(action: @escaping () -> Void) -> ItemViewModel {
            
            let buttonViewModel = LatestPaymentButtonVM(id: 0,
                                                        avatar: .icon(.ic24Star, .iconBlack),
                                                        topIcon: nil,
                                                        description: "Шаблоны",
                                                        amount: "",
                                                        action: action)
            
            return .templates(buttonViewModel)
        }
        
        static func createCurrencyWalletButton(action: @escaping () -> Void) -> ItemViewModel {
            
            let buttonViewModel = LatestPaymentButtonVM(id: -1,
                                                        avatar: .icon(.ic24CurrencyExchange, .iconBlack),
                                                        topIcon: nil,
                                                        description: "Обмен валют",
                                                        amount: "",
                                                        action: action)
            
            return .templates(buttonViewModel)
        }
    }
}

//MARK: - Types

extension LatestPaymentsView.ViewModel {
    
    enum Filter {
        
        case including(Set<LatestPaymentData.Kind>)
        case excluding(Set<LatestPaymentData.Kind>)
    }
    
    enum Mode {
        
        case regular
        case extended
    }
    
    struct PlaceholderViewModel: Identifiable {
        
        let id = UUID()
    }
    
    struct LatestPaymentButtonVM: Identifiable {
        
        let id: LatestPaymentData.ID
        let avatar: Avatar
        let topIcon: Image?
        let description: String
        let amount: String?
        let action: () -> Void
        
        enum Avatar {
            case image(Image)
            case text(String)
            case icon(Image, Color)
        }
    }
    
    enum ItemViewModel: Identifiable {
        
        case templates(LatestPaymentButtonVM)
        case currencyWallet(LatestPaymentButtonVM)
        case latestPayment(LatestPaymentButtonVM)
        case placeholder(PlaceholderViewModel)
        
        var id: String {
            
            switch self {
            case let .templates(templatesButtonViewModel): return String(templatesButtonViewModel.id)
            case let .currencyWallet(currencyButtonViewModel): return String(currencyButtonViewModel.id)
            case let .latestPayment(latestPaymentButtonVM): return String(latestPaymentButtonVM.id)
            case let .placeholder(placeholderViewModel): return placeholderViewModel.id.uuidString
            }
        }
    }
}

//MARK: LatestPaymentButtonVM init

extension LatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
    init(data: LatestPaymentData, model: Model, mode: LatestPaymentsView.ViewModel.Mode? = .regular, action: @escaping () -> Void) {
        
        func amountValue (mode: LatestPaymentsView.ViewModel.Mode, data: LatestPaymentData) -> String? {
            
            switch mode {
                
            case .regular:
                return nil
                
            case .extended:
                switch (data.type, data) {
                    
                case (.internet, let paymentData as PaymentServiceData),
                    (.service, let paymentData as PaymentServiceData),
                    (.transport, let paymentData as PaymentServiceData):
                    return "\(model.amountFormatted(amount: paymentData.amount, currencyCode: "RUB", style: .normal) ?? "")"
                default:
                    return nil
                }
            }
        }
        
        let icon: Avatar = .icon(data.type.defaultIcon, .iconGray)
        let name = data.type.defaultName
        
        switch (data.type, data) {
        case (.phone, let paymentData as PaymentGeneralData):
            
            let phoneNumberRu = paymentData.phoneNumberRu
            
            self.avatar = model.avatar(for: phoneNumberRu) ?? icon
            self.topIcon = model.dictionaryBank(for: paymentData.bankId)?.svgImage.image
            self.description = model.fullName(for: phoneNumberRu)
            
            
        case (.outside, let paymentData as PaymentServiceData):
            
            let outsideData = Self.reduceAdditional(model: model, additionalList: paymentData.additionalList)
            
            self.avatar = outsideData.avatar ?? icon
            self.description = outsideData.description ?? name
            self.topIcon = outsideData.topIcon
        
        case (.transport, let paymentData as PaymentServiceData),
            (.taxAndStateService, let paymentData as PaymentServiceData):
            
            let operatorData = Self.reduceAnywayOperator(anywayOperators: model.dictionaryAnywayOperators(), puref: paymentData.puref)
            
            self.avatar = operatorData.avatar ?? icon
            self.description = operatorData.description ?? name
            self.topIcon = nil

        case (.internet, let paymentData as PaymentServiceData),
            (.service, let paymentData as PaymentServiceData):
            
            let operatorData = Self.reduceAnywayOperator(anywayOperators: model.dictionaryAnywayOperators(), puref: paymentData.puref)
            
            self.avatar = operatorData.avatar ?? icon
            self.description = operatorData.description ?? name
            self.topIcon = nil
            
        case (.mobile, let paymentData as PaymentServiceData):
            
            if let phoneNumber = paymentData.additionalList.first?.fieldValue,
               !phoneNumber.isEmpty {
                
                let phoneNumberRu = "+7" + phoneNumber
                let phoneFormatter = PhoneNumberKitFormater()
                
                self.avatar = model.avatar(for: phoneNumberRu) ?? icon
                self.description = model.fullName(for: phoneNumberRu)
                
            } else {
                
                self.avatar = icon
                self.description = name
            }
            
            self.topIcon = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image
            
        default: //error matching, init default
            self.avatar = icon
            self.description = name
            self.topIcon = nil
            
        }
        
        self.action = action
        self.id = data.id
        self.amount = amountValue(mode: mode ?? .regular, data: data)
    }
}

//MARK: Model Helpers

extension Model {
    
    func fullName(for phoneNumber: String) -> String {

        let phoneFormatter = PhoneNumberKitFormater()
        
        if case .available = self.contactsPermissionStatus,
           let contact = self.contact(for: phoneNumber) {
            
            return contact.fullName ?? phoneFormatter.partialFormatter(phoneNumber)

        } else {
            
            return phoneFormatter.partialFormatter(phoneNumber)
        }
    }
    
    typealias Avatar = LatestPaymentsView.ViewModel.LatestPaymentButtonVM.Avatar
    
    func avatar(for phoneNumber: String) -> Avatar? {
        
        guard case .available = self.contactsPermissionStatus,
              let contact = self.contact(for: phoneNumber)
        else { return nil }
        
        if let avatar = contact.avatar,
           let avatarImg = Image(data: avatar.data) {
            
            return .image(avatarImg)
            
        } else if let initials = contact.initials {
            
            return .text(initials)
            
        } else {
            
            return nil
        }
    }
}

//MARK: LatestPaymentButtonVM reducer's

extension LatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
    static func reduceAnywayOperator(anywayOperators: [OperatorGroupData.OperatorData]?, puref: String) -> (avatar: Avatar?, description: String?) {
        
        guard let anywayOperators = anywayOperators,
              let anyOperator = anywayOperators.first(where: { $0.code == puref } ) else {
            
            return (nil, nil)
        }
        
        let description = anyOperator.name
        if let avatar = anyOperator.logotypeList.first?.svgImage?.image {
            
            return (.image(avatar), description)
            
        } else {
            
            return (nil, description)
        }
    }
    
    static func reduceAdditional(model: Model, additionalList: [PaymentServiceData.AdditionalListData]) -> (avatar: Avatar?, description: String?, topIcon: Image?) {
        
        let topIcon = Self.topIconOutside(model: model, additionalList: additionalList)
        
        if let phone = additionalList.first(where: { $0.isPhone })?.fieldValue {
            
            return (model.avatar(for: phone), model.fullName(for: phone), topIcon)
            
        } else if let fullName = additionalList.fullName {
            
            return (nil, fullName, topIcon)
        }
        
        return (nil, nil, nil)
    }
    
    static func topIconOutside(model: Model, additionalList: [PaymentServiceData.AdditionalListData]) -> Image? {
        
        guard let countryId = additionalList.first(where: { $0.isCountry } )?.fieldValue,
              let country = model.countriesList.value.first(where: { $0.id == countryId } ),
              let image = country.svgImage?.image else {
            
            return nil
        }
        
        return image
    }
    
    static func firstLetter(name: String, lastName: String) -> String {
        
        let letters = [name, lastName]
            .compactMap { $0?.replacingOccurrences(of: " ", with: "").first }
            .map{ $0.uppercased() }
            .reduce("", +)
        
        return letters
    }
}

//MARK: - Action PTSectionLatestPaymentsViewAction

enum LatestPaymentsViewModelAction {
    
    enum ButtonTapped {
        
        struct Templates: Action {}
        
        struct CurrencyWallet: Action {}
        
        struct LatestPayment: Action {
            
            let latestPayment: LatestPaymentData
        }
    }
}

//MARK: - View

struct LatestPaymentsView: View {
    
    @ObservedObject private var viewModel: LatestPaymentsView.ViewModel

    private let iconSize: CGFloat

    init(
        viewModel: LatestPaymentsView.ViewModel,
        iconSize: CGFloat = 56
    ) {
        self.viewModel = viewModel
        self.iconSize = iconSize
    }
    
    var body: some View {
        
        ScrollView(.horizontal,showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(viewModel.items) { item in
                    
                    switch item {
                    case let .templates(templateVM):
                        LatestPaymentButtonView(viewModel: templateVM)
                        
                    case let .currencyWallet(currencyWalletButtonViewModel):
                        LatestPaymentButtonView(viewModel: currencyWalletButtonViewModel)
                        
                    case let .latestPayment(latestPaymentVM):
                        LatestPaymentButtonView(
                            viewModel: latestPaymentVM,
                            iconSize: iconSize
                        )
                        
                    case let .placeholder(placeholderVM):
                        PlaceholderView(viewModel: placeholderVM)
                            .shimmering(active: true, bounce: true)
                    }
                }
                
                Spacer()
                
            }
            .padding(.leading, 8)
        }
    }
}

//MARK: - PlaceholderView

extension LatestPaymentsView {
    
    struct PlaceholderView: View {
        
        let viewModel: ViewModel.PlaceholderViewModel
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 8) {
                
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 56, height: 56)
                
                VStack(alignment: .center, spacing: 8) {
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 65, height: 8, alignment: .center)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 45, height: 8, alignment: .center)
                }
                .foregroundColor(.mainColorsGray.opacity(0.4))
                .frame(width: 80, height: 32)
            }
            
        }
    }
}

//MARK: - LatestPaymentButtonView

extension LatestPaymentsView {
    
    struct LatestPaymentButtonView: View {
        
        private let viewModel: ViewModel.LatestPaymentButtonVM
        private let iconSize: CGFloat

        init(
            viewModel: ViewModel.LatestPaymentButtonVM,
            iconSize: CGFloat = 56
        ) {
            self.viewModel = viewModel
            self.iconSize = iconSize
        }
        
        var body: some View {
            
            Button(action: viewModel.action, label: {
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(height: iconSize)
                            .accessibilityIdentifier("LatestPaymentsAvatarIcon")
                        
                        switch viewModel.avatar {
                        case let .image(image):
                            
                            image
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: iconSize)
                            
                        case let .text(text):
                            Text(text)
                                .font(.textH4M16240())
                                .foregroundColor(.textPlaceholder)
                            
                        case let .icon(icon, color):
                            icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                        }
                        
                        if let topIcon = viewModel.topIcon {
                            topIcon
                                .renderingMode(.original)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 24, height: 24)
                                .position(x: 64, y: 12)
                                .accessibilityIdentifier("LatestPaymentsTopIcon")
                        }
                    }
                    
                    if let amountValue = viewModel.amount,
                       !amountValue.isEmpty {
                        
                        VStack(alignment: .center, spacing: 0) {
                            
                            Text(viewModel.description)
                                .font(.textBodySR12160())
                                .lineLimit(1)
                                .foregroundColor(.textSecondary)
                                .frame(width: 80, alignment: .top)
                                .multilineTextAlignment(.center)
                            
                            Text(amountValue)
                                .font(.textBodySR12160())
                                .lineLimit(1)
                                .foregroundColor(.textRed)
                                .frame(width: 80, height: 16, alignment: .top)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        
                        Text(viewModel.description)
                            .font(.textBodySR12160())
                            .lineLimit(2)
                            .foregroundColor(.textSecondary)
                            .frame(width: 80, height: 32, alignment: .top)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("LatestPaymentsName")
                    }
                }
                .frame(width: 80, height: 96)
            })
            .accessibilityIdentifier("LatestPaymentsItem")
            
        }
    }
}



struct LatestPaymentsViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        LatestPaymentsView(viewModel: .init(.emptyMock,
                                            mode: .regular, items: [], isBaseButtons: true, filter: nil))
    }
}
