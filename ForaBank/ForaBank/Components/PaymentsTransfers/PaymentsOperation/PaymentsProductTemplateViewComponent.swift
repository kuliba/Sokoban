//
//  PaymentsProductTemplateViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.02.2023.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsProductTemplateView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var contentState: ContentState
        @Published var alertData: AlertDataViewModel? = nil
        @Published var cardScanner: CardScannerViewModel?
        
        private let model: Model
        
        var parameter: Payments.ParameterProductTemplate? {
            source as? Payments.ParameterProductTemplate
        }
        
        override var isValid: Bool {
            guard let parameterValue = Payments.ParameterProductTemplate.ParametrValue
                                        .init(stringValue: value.current)
            else { return false }
            
            switch parameterValue {
            case .cardNumber(let string):
                
                return parameter?.validator.isValid(value: string) ?? false
                
            case .templateId:
                return true
            }
        }

        init(model: Model = .emptyMock,
             contentState: ContentState,
             source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.model = model
            self.contentState = contentState
            super.init(source: source)
        }

        convenience init(_ model: Model, parameter: Payments.ParameterProductTemplate) {
            
            let templateListViewModel = Self.reduce(data: model.productTemplates.value)
            
            var productTemplateState = ProductTemplateViewModel.ProductTemplateState.placeholder(
                                        .init(title: parameter.title,
                                              cardIcon: nil,
                                              nameLine: .init(paymentIcon: nil,
                                                              name: parameter.placeholder,
                                                              isNameGray: true)))
            
            switch parameter.parameterValue {
            case let .cardNumber(cardNumber):
                
                let numberCardMasked = Self.maskCardNumber(number: cardNumber,
                                                          mask: parameter.mask,
                                                          masked: parameter.masked)
                
                productTemplateState = .twoLines(.init(cardIcon: nil,
                                                       nameLine: .init(paymentIcon: nil,
                                                                       name: numberCardMasked)))
            
            case let .templateId(templateId):
                
                guard let data = model.productTemplate(for: templateId) else { break }
                
                productTemplateState = Self.reduce(data: data)
                
            case .none: break
            }
            
            let productTemplateViewModel = ProductTemplateViewModel
                                            .init(model: model,
                                                  productTemplateState: productTemplateState,
                                                  isCollapsed: true,
                                                  templateList: templateListViewModel)
            self.init(model: model,
                      contentState: .productTemplate(productTemplateViewModel),
                      source: parameter)
            
            bind()
            bind(productTemplateViewModel)
            bind(templateListViewModel)
        }
        
        enum ContentState {
            case productTemplate(ProductTemplateViewModel)
            case editableMode(EditModeViewModel)
        }
        
        struct AlertDataViewModel: Identifiable {
            
            var id: Int
            let title: String
            let message: String
            let secondaryButtonTitle: String
        }
        
//MARK: - ProductTemplate ViewModel productTemplateState
        
        class ProductTemplateViewModel: ObservableObject {
            
            @Published var productTemplateState: ProductTemplateState
            @Published var isCollapsed: Bool
            @Published var templateList: TemplateListViewModel
           
            let model: Model
            
            init(model: Model,
                 productTemplateState: ProductTemplateState,
                 isCollapsed: Bool = true,
                 templateList: TemplateListViewModel) {
                
                self.model = model
                self.productTemplateState = productTemplateState
                self.isCollapsed = isCollapsed
                self.templateList = templateList
            }
            
            enum ProductTemplateState {
                
                case placeholder(TwoLinesViewModel)
                case twoLines(TwoLinesViewModel)
                case threeLines(ThreeLinesViewModel)
            }
            
            //MARK: - ProductTemplate TwoLines ViewModel
            class TwoLinesViewModel: ObservableObject {
                
                let title: String
                
                @Published var cardIcon: Image?
                @Published var nameLine: NameLineViewModel
                
                init(title: String = "Куда",
                     cardIcon: Image? = nil,
                     nameLine: NameLineViewModel = .init()) {
                    
                    self.title = title
                    self.cardIcon = cardIcon
                    self.nameLine = nameLine
                }
            }
            
            //MARK: - ProductTemplate ThreeLines ViewModel
            class ThreeLinesViewModel: ObservableObject {
                
                let title: String
                
                @Published var cardIcon: Image?
                @Published var nameLine: NameLineViewModel
                @Published var numberCardSuffix: String
                
                init(title: String = "Куда",
                     cardIcon: Image? = nil,
                     nameLine: NameLineViewModel,
                     numberCardSuffix: String) {
                    
                    self.title = title
                    self.cardIcon = cardIcon
                    self.nameLine = nameLine
                    self.numberCardSuffix = numberCardSuffix
                }
            }
            
            //MARK: - ProductTemplate NameLine ViewModel
            class NameLineViewModel: ObservableObject {
                
                @Published var paymentIcon: Image?
                @Published var name: String
                @Published var isNameGray: Bool
                
                init(paymentIcon: Image? = nil,
                     name: String = "Номер карты",
                     isNameGray: Bool = false) {
                    
                    self.paymentIcon = paymentIcon
                    self.name = name
                    self.isNameGray = isNameGray
                }
            }
            
            
            //MARK: - TemplateList ViewModel
            
            class TemplateListViewModel: ObservableObject {

                @Published var isDeleteItemsMode: Bool
                @Published var list: [TemplateItemViewModel]
                
                let title: String
                let action: PassthroughSubject<Action, Never> = .init()

                init(title: String = "Добавить",
                     isDeleteItemsMode: Bool = false,
                     list: [TemplateItemViewModel]) {

                    self.list = list
                    self.title = title
                    self.isDeleteItemsMode = isDeleteItemsMode
                }
            }
            
            //MARK: - TemplateItem ViewModel
            
            class TemplateItemViewModel: Identifiable {
                
                let id: Int
                let numberPostfix: String
                let name: String
                let paymentSystemImg: Image?
                let backgroundImg: Image?
                
                init(id: Int,
                     name: String,
                     numberPostfix: String,
                     backgroundImg: Image?,
                     paymentSystemImg: Image?) {
                    
                    self.id = id
                    self.numberPostfix = numberPostfix
                    self.name = name
                    self.backgroundImg = backgroundImg
                    self.paymentSystemImg = paymentSystemImg
                }
            }
            
        }
        
//MARK: - EditMode ViewModel editableModeState
        
        class EditModeViewModel: ObservableObject {
            
            let action: PassthroughSubject<Action, Never> = .init()
            
            let textField: TextFieldMaskableView.ViewModel
            let title: String
            
            init(textField: TextFieldMaskableView.ViewModel,
                 title: String = "Введите номер карты") {
                
                self.textField = textField
                self.title = title
            }
        }
        
//MARK: - Static Reduce ViewModels
        
        static func reduce(data: [ProductTemplateData]) -> ProductTemplateViewModel.TemplateListViewModel {
            
            let list = data.map { itemData -> ProductTemplateViewModel.TemplateItemViewModel in
                
                var name = itemData.customName
                
                switch Self.reduce(data: itemData) {
                 
                case .twoLines: name = ""
                default: break
                    
                }
                
                return ProductTemplateViewModel.TemplateItemViewModel
                    .init(id: itemData.id,
                          name: name,
                          numberPostfix: String(itemData.numberMask.suffix(4)),
                          backgroundImg: nil, //todo in back
                          paymentSystemImg: itemData.paymentSystemImage?.image)
            }
            
            return .init(list: list)
        }
        
        static func reduce(data: ProductTemplateData) -> ProductTemplateViewModel.ProductTemplateState {
            
            if data.numberMask == data.customName || data.customName.isEmpty {
                
                return .twoLines(.init(cardIcon: data.smallDesign.image,
                                       nameLine: .init(paymentIcon: data.paymentSystemImage?.image,
                                                       name: data.numberMask)))
            } else {
            
                return .threeLines(.init(nameLine: .init(paymentIcon: data.paymentSystemImage?.image,
                                                         name: data.customName),
                                         numberCardSuffix: String(data.numberMask.suffix(4))))
            }
        }
        
//MARK: - Static Helpers
        
        static func maskCardNumber(number: String,
                                   mask: StringValueMask,
                                   masked: Payments.ParameterProductTemplate.CardMaskData ) -> String {
            
            var newStr = number.masked(mask: mask)
            
            guard newStr.count == mask.mask.count else { return newStr }
            
            for n in masked.range {
            
                newStr = newStr.prefix(n) + masked.symbol + newStr.dropFirst(n + 1)
            }
            
            return newStr
        }
        
//MARK: - binds
        
        private func bind() {
            
            action
                .compactMap { $0 as? PaymentsProductTemplateAction.Header.Tap }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] payload in
                    
                    guard let parameter = parameter else { return }
                    
                    if payload.viewModel.templateList.list.isEmpty {
                    
                        let editModeViewModel = EditModeViewModel
                            .init(textField: .init(masks: [parameter.mask],
                                                   regExp: "",
                                                   toolbar: .init(doneButton: .init(isEnabled: true, action: { UIApplication.shared.endEditing()}))))
                        bind(editModeViewModel)
                        
                        self.contentState = .editableMode(editModeViewModel)
                    
                    } else {
                        
                        guard parameter.isEditable else { return }
                        
                        withAnimation {
                            payload.viewModel.isCollapsed.toggle()
                        }
                    }
                }
                .store(in: &bindings)
            
            
            action
                .compactMap { $0 as? PaymentsProductTemplateAction.TemplateList.DeleteItem }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] payload in
                    
                    switch contentState {
                    case let .productTemplate(productTemplateViewModel):
                        
                        guard let data = model.productTemplates.value.first(where: { $0.id == payload.id }),
                              let dataIndex = model.productTemplates.value.firstIndex(where: { $0.id == payload.id }),
                              let itemIndex = productTemplateViewModel.templateList.list.firstIndex(where: { $0.id == payload.id })
                        else { return }
                        
                        self.alertData = nil
                        
                        model.productTemplates.value.remove(at: dataIndex)
                        model.action.send(ModelAction.ProductTemplate.Delete.Request(productTemplateId: data.id))
                        
                        withAnimation {
                            
                            let deletedItem = productTemplateViewModel.templateList.list.remove(at: itemIndex)
                            
                            if let parameter = parameter,
                               case let .templateId(templateId) = parameter.parameterValue,
                               templateId == String(deletedItem.id) {
                                
                                productTemplateViewModel.productTemplateState = .placeholder(
                                    .init(title: parameter.title,
                                          cardIcon: nil,
                                          nameLine: .init(paymentIcon: nil,
                                                          name: parameter.placeholder,
                                                          isNameGray: true)))
                                
                                update(value: nil)
                            }
                        }
                        
                    default: return
                        
                    }
                }
                .store(in: &bindings)
        }
        
        //bind ProductTemplateViewModel
        private func bind(_ templateViewModel: ProductTemplateViewModel) {
            
            templateViewModel.model.productTemplates
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] templates in
                    
                    let templateListViewModel = Self.reduce(data: templates)
                    bind(templateListViewModel)
                    
                    templateViewModel.templateList = templateListViewModel
                }
                .store(in: &bindings)
        }
        
        private func bind(_ templateListViewModel: ProductTemplateViewModel.TemplateListViewModel) {
            
            templateListViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.TemplateList.NewTap }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                
                    guard let parameter = parameter else { return }

                    let editModeViewModel = EditModeViewModel
                        .init(textField: .init(masks: [parameter.mask],
                                               regExp: "",
                                               toolbar: .init(doneButton: .init(isEnabled: true, action: { UIApplication.shared.endEditing()}))))
                    bind(editModeViewModel)
                    self.contentState = .editableMode(editModeViewModel)
                    
                }
                .store(in: &bindings)
            
            
            templateListViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.TemplateList.TemplateTap }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] payload in

                    if templateListViewModel.isDeleteItemsMode {
                        
                        templateListViewModel.isDeleteItemsMode = false
                        
                    } else {
                    
                        switch contentState {
                        case let .productTemplate(productTemplateViewModel):
                        
                            guard let data = model.productTemplates.value.first(where: { $0.id == payload.id })
                            else { return }
                        
                            productTemplateViewModel.productTemplateState = Self.reduce(data: data)
                            productTemplateViewModel.isCollapsed = true
                        
                            let parameterValue = Payments.ParameterProductTemplate.ParametrValue.templateId("\(data.id)")
                            update(value: parameterValue.stringValue)
                        
                        default: return
                        
                        }
                    }
                }
                .store(in: &bindings)
            
            
            templateListViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.TemplateList.DeleteTap }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] payload in
                    
                    self.alertData = AlertDataViewModel(id: payload.id,
                                                        title: "Удалить карту?",
                                                        message: "Вы действительно хотите удалить карту?",
                                                        secondaryButtonTitle: "Удалить")
                }
                .store(in: &bindings)
            
            
            templateListViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.TemplateList.LongTap }
                .receive(on: DispatchQueue.main)
                .sink { _ in
                
                    withAnimation {
                        templateListViewModel.isDeleteItemsMode.toggle()
                    }
                    
                }
                .store(in: &bindings)
        }
        
        //bind EditModeViewModel
        private func bind(_ editViewModel: EditModeViewModel) {
        
            editViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.EditableMode.Close }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    guard let parameter = parameter else { return }

                    let templateListViewModel = Self.reduce(data: model.productTemplates.value)
                    
                    let productTemplateViewModel = ProductTemplateViewModel
                        .init(model: model,
                              productTemplateState: .placeholder(
                                .init(title: parameter.title,
                                      cardIcon: nil,
                                      nameLine: .init(paymentIcon: nil,
                                                      name: parameter.placeholder,
                                                      isNameGray: true))),
                              isCollapsed: true,
                              templateList: templateListViewModel)
                    
                    bind(productTemplateViewModel)
                    bind(templateListViewModel)
                    
                    update(value: nil)
                    
                    self.contentState = .productTemplate(productTemplateViewModel)
                
            }.store(in: &bindings)
            
            
            editViewModel.action
                .compactMap { $0 as? PaymentsProductTemplateAction.EditableMode.ShowScanner }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    LoggerAgent.shared.log(category: .ui, message: "received PaymentsProductTemplateAction.EditableMode.ShowScanner")
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented card scanner")
                    
                    self.cardScanner = .init(closeAction: { number in
                        
                        guard let value = number
                        else {
                            self.cardScanner = nil
                            return
                        }
                        
                        let filterredValue = (try? value.filterred(regEx: editViewModel.textField.regExp)) ?? value
                        let maskedValue = filterredValue.masked(masks: editViewModel.textField.masks)
                        editViewModel.textField.text = maskedValue
                        
                        self.cardScanner = nil
                    })
                
            }.store(in: &bindings)
            
            
            editViewModel.textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                
                if text == "" {
                    
                    update(value: nil)
                    
                } else {
                    
                    if let cleanText = text?.replacingOccurrences(of: " ", with: "") {
                        
                        let parameterValue = Payments.ParameterProductTemplate.ParametrValue.cardNumber(cleanText)
                        
                        update(value: parameterValue.stringValue)
                        
                    } else {
                        
                        update(value: nil)
                    }
                }
                
            }.store(in: &bindings)
        }
        
    }
}

// MARK: - Action

enum PaymentsProductTemplateAction {
    
    enum TemplateList {
        
        struct NewTap: Action {}
        
        struct LongTap: Action {}
        
        struct TemplateTap: Action {
            
            let id: Int
        }
        
        struct DeleteTap: Action {
            
            let id: Int
        }
        
        struct DeleteItem: Action {
            
            let id: Int
        }
    }
    
    enum Header {

        struct Tap: Action {
            
            let viewModel: PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel
        }
    }
    
    enum EditableMode {

        struct End: Action {}
        struct Close: Action {}
        struct ShowScanner: Action {}
    }
}


//MARK: - View

struct PaymentsProductTemplateView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        switch viewModel.contentState {
        case let .productTemplate(productTemplateViewModel):
            
            ProductTemplateView(viewModel: productTemplateViewModel, isEditable: $viewModel.isEditable)
                .padding(.horizontal, 12)
                .padding(.vertical, 22)
                .onTapGesture {
                    if viewModel.isEditable {
                        viewModel.action.send(PaymentsProductTemplateAction.Header.Tap
                            .init(viewModel: productTemplateViewModel))
                    }
                }
                .alert(item: $viewModel.alertData) { alertData in
                    Alert(title: Text(alertData.title),
                          message: Text(alertData.message),
                          primaryButton: Alert.Button.cancel(),
                          secondaryButton: Alert.Button.destructive(Text(alertData.secondaryButtonTitle),
                                                                    action: {
                        viewModel.action.send(PaymentsProductTemplateAction.TemplateList.DeleteItem(id: alertData.id)) }) )
                }
        
        case let .editableMode(editModeViewModel):
            
                        ProductTemplateEditModeView(viewModel: editModeViewModel)
                .padding(.horizontal, 12)
                .padding(.vertical, 22)
                .present(item: $viewModel.cardScanner,
                         style: .overFullScreen,
                         content: { cardScannerViewModel in
                    
                                    CardScannerView(viewModel: cardScannerViewModel)
                                        .edgesIgnoringSafeArea(.all)
                })
                .onAppear { editModeViewModel.textField.activateKeyboard() }
        }
    }
}

extension PaymentsProductTemplateView {
    
    struct CardPlaceholderView: View {
        var body: some View {
            
            ZStack {
    
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.bordersDivider)
                    .frame(width: 32, height: 22)
        
                Image.ic24Bank
                    .resizable()
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 14, height: 13)
            }
        }
    }
    
//MARK: - TemplateList View
    
    struct TemplateListView: View {
        
        @ObservedObject var viewModel: ViewModel.ProductTemplateViewModel.TemplateListViewModel
        
        var body: some View {
            
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(alignment: .top, spacing: 8) {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 72, height: 72)
                                .foregroundColor(.bordersDivider)
                            
                            VStack(spacing: 14) {
                                
                                Image.ic24NewCard
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text(viewModel.title)
                                    .font(.textBodySM12160())
                                    
                            }.foregroundColor(.textSecondary)
                        }
                        .padding(.top, 8)
                        .onTapGesture {
                            viewModel.action.send(PaymentsProductTemplateAction.TemplateList.NewTap())
                        }
                        
                        ForEach(viewModel.list) { template in
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 86, height: 54)
                                    .foregroundColor(.mainColorsBlack)
                                    .opacity(0.3)
                                    .offset(x: 0, y: 13)
                                    .blur(radius: 9)
        
                                if let background = template.backgroundImg {
                                    
                                    background
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                    
                                } else {
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 112, height: 72)
                                        .foregroundColor(.bordersDivider)
                                }
                                    
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    HStack(spacing: 4) {
                                    
                                        Image.ic24LogoForaOneColor
                                        .resizable()
                                        .frame(width: 17, height: 16)
                                        
                                        Circle()
                                            .frame(width: 2, height: 2)
                                            .foregroundColor(.textPrimary)
                                    
                                        Text(template.numberPostfix)
                                        .font(.textBodyXSR11140())
                                        .foregroundColor(.textPrimary)
                                    }
                                    .padding(.bottom, 9)
                                        
                                    Text(template.name)
                                        .font(.textBodyXSR11140())
                                        .foregroundColor(.textPrimary)
                                        .opacity(0.5)
                                    
                                    Spacer()
                                    
                                } //vstack
                                .padding(10)
                                .frame(width: 112, height: 72, alignment: .leading)
                                
                                if let paymentSysImg = template.paymentSystemImg {
                                
                                    paymentSysImg
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.iconBlackMedium)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .frame(maxWidth: .infinity,
                                               maxHeight: .infinity,
                                               alignment: .bottomTrailing)
                                } else {
                                
                                   EmptyView()
                                // TODO: crash preview https://developer.apple.com/forums/thread/654018
                                }
                                
                                if viewModel.isDeleteItemsMode {
                                    
                                    Image.ic24Close
                                        .resizable()
                                        .foregroundColor(.iconWhite)
                                        
                                        .background(Color.mainColorsGray)
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                        .offset(x: 52, y: -34)
                                        .onTapGesture {
                                            viewModel.action.send(PaymentsProductTemplateAction.TemplateList.DeleteTap(id: template.id))
                                        }
                               
                                } else {
                                    
                                    EmptyView()
                                // TODO: crash preview https://developer.apple.com/forums/thread/654018
                                }
                                
                            }
                            .frame(width: 112, height: 72)
                            .padding(.top, 8)
                            .padding(.bottom, 18)
                            .onTapGesture {
                                viewModel.action.send(PaymentsProductTemplateAction.TemplateList.TemplateTap(id: template.id))
                            }
                            .onLongPressGesture {
                                viewModel.action.send(PaymentsProductTemplateAction.TemplateList.LongTap())
                            }
                        } //forE
                            
                    }
                }
        }
    }
    
//MARK: - ProductTemplateView
    
    struct ProductTemplateView: View {
        
        @ObservedObject var viewModel: ViewModel.ProductTemplateViewModel
        @Binding var isEditable: Bool
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                switch viewModel.productTemplateState {
                    
                case let .placeholder(placeholderViewModel):
                    
                    TwoLinesView(viewModel: placeholderViewModel,
                                 isEditable: $isEditable,
                                 isCollapsed: $viewModel.isCollapsed,
                                 templateList: $viewModel.templateList.list)
                
                case let .twoLines(twoLinesViewModel):
                    
                    TwoLinesView(viewModel: twoLinesViewModel,
                                 isEditable: $isEditable,
                                 isCollapsed: $viewModel.isCollapsed,
                                 templateList: $viewModel.templateList.list)
                    
                case let .threeLines(threeLinesViewModel):
                    
                    ThreeLinesView(viewModel: threeLinesViewModel,
                                   isEditable: $isEditable,
                                   isCollapsed: $viewModel.isCollapsed)
                }
            
                if !viewModel.isCollapsed {
                
                    PaymentsProductTemplateView.TemplateListView(viewModel: viewModel.templateList)
                }
            }
        }
    }
    
    
//MARK: - ProductTemplateEditModeView
    
    struct ProductTemplateEditModeView: View {
        
        @ObservedObject var viewModel: ViewModel.EditModeViewModel
        
        var body: some View {
            
            HStack(spacing: 12) {
                
                PaymentsProductTemplateView.CardPlaceholderView()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                    
                    TextFieldMaskableView(viewModel: viewModel.textField,
                                          font:   UIFont(name: "Inter-Medium", size: 16.0)!,
                                          backgroundColor: .mainColorsGrayLightest,
                                          textColor: .textSecondary,
                                          tintColor: .black)
                        .textContentType(.creditCardNumber)
                }
                
                Image.ic24BarcodeScanner2
                    .resizable()
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        viewModel.action.send(PaymentsProductTemplateAction.EditableMode.ShowScanner())
                    }
                
                Image.ic24Close
                    .resizable()
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        viewModel.action.send(PaymentsProductTemplateAction.EditableMode.Close())
                    }
                
            }.frame(height: 60)
            
        }
    }
}

extension PaymentsProductTemplateView.ProductTemplateView {
    
    struct NameLineView: View {
        
        @ObservedObject var viewModel: PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel.NameLineViewModel
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 10) {
                
                if let paymentIcon = viewModel.paymentIcon {
                    
                    paymentIcon
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                Text(viewModel.name)
                    .font(.textH4M16240())
                    .foregroundColor(viewModel.isNameGray ? .textPlaceholder
                                                          : .textSecondary)
            }
        }
    }
    
    struct TwoLinesView: View {
        
        @ObservedObject var viewModel: PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel.TwoLinesViewModel
        
        @Binding var isEditable: Bool
        @Binding var isCollapsed: Bool
        @Binding var templateList: [PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel.TemplateItemViewModel]
        
        var body: some View {
            
            HStack(spacing: 12) {
                
                PaymentsProductTemplateView.CardPlaceholderView()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                    
                    PaymentsProductTemplateView.ProductTemplateView.NameLineView
                        .init(viewModel: viewModel.nameLine)
                   
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                
                if !templateList.isEmpty,
                   isEditable {
                    
                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsGray)
                        .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                }
            }
            
        }
    }
    
    struct ThreeLinesView: View {
        
        @ObservedObject var viewModel: PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel.ThreeLinesViewModel
        
        @Binding var isEditable: Bool
        @Binding var isCollapsed: Bool
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14180())
                    .foregroundColor(.textPlaceholder)
                    .padding(.leading, 48)
                    .padding(.bottom, 4)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    if let cardIcon = viewModel.cardIcon {
                        
                        ZStack(alignment: .topLeading) {
                
                            cardIcon
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 22)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .foregroundColor(.bordersDivider)
                                .frame(width: 32, height: 22)
                    
                            Image.ic24LogoForaOneColor
                                .resizable()
                                .foregroundColor(.mainColorsGray)
                                .frame(width: 8, height: 7)
                                .padding(5)
                        }
                    
                    } else {
                            
                        PaymentsProductTemplateView.CardPlaceholderView()
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        
                        HStack(alignment: .center, spacing: 10) {
                            
                            PaymentsProductTemplateView.ProductTemplateView.NameLineView
                                .init(viewModel: viewModel.nameLine)
                        
                            Spacer()
                        
                            if isEditable {
                            
                                Image.ic24ChevronDown
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.mainColorsGray)
                                    .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                            }
                        }
                        
                        HStack {
                            
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(.mainColorsGray)
                                
                            Text(viewModel.numberCardSuffix)
                                .font(.textBodyMR14180())
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
                
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            
        }
    }
    
}


//MARK: - Preview

struct PaymentsProductToView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsProductTemplateView(viewModel: .samplePlaceholder)
                .previewLayout(.fixed(width: 300, height: 250))
            
            PaymentsProductTemplateView(viewModel: .sampleEdit)
                .previewLayout(.fixed(width: 300, height: 70))
            
            PaymentsProductTemplateView(viewModel: .sampleThreeLines)
                .previewLayout(.fixed(width: 300, height: 290))
    
        }
    }
}

//MARK: - Preview Content

extension PaymentsProductTemplateView.ViewModel {
    
    static let samplePlaceholder = PaymentsProductTemplateView.ViewModel
        .init(model: .emptyMock,
              contentState: .productTemplate(.init(model: .emptyMock,
                                                   productTemplateState: .placeholder(
                                                        .init(title: "Куда",
                                                              cardIcon: nil,
                                                              nameLine: .init(paymentIcon: nil,
                                                                              name: "Номер Карт",
                                                                              isNameGray: true))),
                                                   isCollapsed: false,
                                                   templateList: PaymentsProductTemplateView.ViewModel.sampleListTemplate)))
    
    static let sampleThreeLines = PaymentsProductTemplateView.ViewModel
                .init(model: .emptyMock,
                      contentState: .productTemplate(
                        .init(model: .emptyMock,
                              productTemplateState: .threeLines(.init(title: "Куда",
                                                                    cardIcon: Image("Classic Card"),
                                                                    nameLine: .init(paymentIcon: Image("Payment System Mir"),
                                                                                    name: "Name cardholder"),
                                                                    numberCardSuffix: "2332")), isCollapsed: false,
                              templateList: PaymentsProductTemplateView.ViewModel.sampleListTemplate)))
    
    static let sampleEdit = PaymentsProductTemplateView.ViewModel
        .init(model: .emptyMock,
                contentState: .editableMode(.init(textField: .init(masks: [.card], regExp: "", toolbar: nil))))
                                            
    
    static let sampleListTemplate: PaymentsProductTemplateView.ViewModel.ProductTemplateViewModel.TemplateListViewModel =
        .init(isDeleteItemsMode: true,
              list:
                [.init(id: 1,
                       name: "Name of Template",
                       numberPostfix: "2345",
                       backgroundImg: nil,
                       paymentSystemImg: Image("Payment System Mir")),
                 .init(id: 2,
                       name: "Name2",
                       numberPostfix: "2222",
                       backgroundImg: nil,
                       paymentSystemImg: nil),
                 .init(id: 3,
                       name: "",
                       numberPostfix: "2323",
                       backgroundImg: nil,
                       paymentSystemImg: Image("Payment System Mir")),
                 .init(id: 4,
                       name: "Name2",
                       numberPostfix: "2222",
                       backgroundImg: nil,
                       paymentSystemImg: Image("Payment System Mastercard"))])


}
