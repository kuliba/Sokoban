//
//  PTSectionLatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Combine

/*

 class Model {

     ...
       //MARK: LatestAllPayments
     let latestPayments: CurrentValueSubject<[PaymentData], Never>
     let latestPaymentsUpdating: CurrentValueSubject<Bool, Never>
     ...
 }

 //  Model+LatestPayments.swift

 extension Model {
     
     func handleLatestPaymentsListRequest() {
         
        guard latestPaymentsUpdating.value == false else { return }

         guard let token = token else {
             handledUnauthorizedCommandAttempt()
             return
         }

         latestPaymentsUpdating.value = true

         ...
      }
 }

 class ViewModel: PaymentsTransfersSectionViewModel {
      
         let action: PassthroughSubject<Action, Never> = .init()
         
         @Published
         var items: [ItemViewModel]
         
         enum ItemViewModel: Identifiable {

             case templates(ButtonIconTextView.ViewModel)
             case latestPayment(LatestPaymentButtonVM)
             case placeholder(PlaceholderViewModel)

             var id: UUID {
              
                switch self {
                case let templates(templatesButtonViewModel): return templatesButtonViewModel.id
                ...
                }
         }

         struct PlaceholderViewModel {

             let id = UUID()
         }
             
 ...

         init(model: Model) {
             self.latestPaymentsButtons = []
             self.model = model
             super.init()

             bind()
             
             latestPaymentsButtons = baseButtons
             model.action.send(ModelAction.LatestPayments.List.Requested())
         }

 ...


 func bind() {
             
             model.latestPayments
                 .combineLatest(model.latestPaymentsUpdating)
                 .receive(on: DispatchQueue.main)
                 .sink { [unowned self] data in

                     let latestPayments = data.0
                     let isLatestPaymentsUpdating = data.1
               
                     var updatedItems = [ItemViewModel]

                     if isLatestPaymentsUpdating == true {
              
                          if latestPayments.isEmpty == false {

                               updatedItems.append(contentsOf: baseButtons)
                               updatedItems.append(.placehoder(.init()))
                               
                               let latestPaymentsItems = latestPayments.map{ ... }
                               updatedItems.appent(contentsOf: latestPaymentsItems)

                           else {
                             
                            updatedItems.append(contentsOf: baseButtons)
                            updatedItems.append(contentsOf: Array(repeating: .placehoder(.init()), count: 4)

                          }
                      
                      } else {

                               updatedItems.append(contentsOf: baseButtons)

                               let latestPaymentsItems = latestPayments.map{ ... }
                               updatedItems.appent(contentsOf: latestPaymentsItems)
                      }

                     withAnimation {
                         
                        items = updatedItems
                     }

                 }.store(in: &bindings)
 }




*/



//MARK: Section ViewModel

extension PTSectionLatestPaymentsView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
     
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published
        var latestPaymentsButtons: [LatestPaymentButtonVM]
        @Published
        var isAnimateState: Bool = false
        
        override var type: PaymentsTransfersSectionType { .latestPayments }
        private let model: Model
        
        private var bindings = Set<AnyCancellable>()
        
        init(latestPaymentsButtons: [LatestPaymentButtonVM], model: Model) {
            self.latestPaymentsButtons = latestPaymentsButtons
            self.model = model
            super.init()
        }
        
        init(model: Model) {
            self.latestPaymentsButtons = []
            self.model = model
            super.init()
            bind()
        }
        
        struct LatestPaymentButtonVM: Identifiable {
               
            let id = UUID()
            let avatar: Avatar
            let topIcon: Image?
            let description: String
            let action: () -> Void

            enum Avatar {
                case image(Image)
                case text(String)
                case icon(Image, Color)
            }
        }
        
        func bind() {
            
            model.action
                .sink { [unowned self] action in
                    switch action {
                    case _ as ModelAction.LatestPayments.List.Requested:
                        self.latestPaymentsButtons = self.baseButtons
                                                + Array(repeating: .init(avatar: .text(""),
                                                                         topIcon: nil,
                                                                         description: "",
                                                                         action: {}),
                                                        count: 4)
                
                        self.isAnimateState = true
                        
                    default: break
                        
                    }
                }.store(in: &bindings)
            
            model.latestPayments
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments in
                    
                    withAnimation {
                        
                        self.latestPaymentsButtons = self.baseButtons
                        
                        guard !latestPayments.isEmpty else {
                            self.isAnimateState = false
                            return
                        }
                        
                        self.model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                        for item in latestPayments {
                            
                            latestPaymentsButtons
                                .append(.init(data: item,
                                              model: self.model,
                                              action: { [weak self] in
                                                        self?.action.send(PTSectionLatestPaymentsViewAction
                                                                         .ButtonTapped
                                                                         .LatestPayment(latestPayment: item)) } ))
                        }
                        self.isAnimateState = false
                    }
                }.store(in: &bindings)
        }
        
        lazy var baseButtons: [LatestPaymentButtonVM] = {
            [
                .init(avatar: .icon(.ic24Star, .iconBlack),
                      topIcon: nil,
                      description: "Шаблоны и автоплатежи",
                      action: { [weak self] in
                          self?.action.send(PTSectionLatestPaymentsViewAction.ButtonTapped.Templates())
                      })
            ]
        }()
    }
}

//MARK: - Action PTSectionLatestPaymentsViewAction

enum PTSectionLatestPaymentsViewAction {

    enum ButtonTapped {

        struct Templates: Action {}

        struct LatestPayment: Action {

            let latestPayment: LatestPaymentData
        }
    }
}

//MARK: Section View

struct PTSectionLatestPaymentsView: View {
    
    @ObservedObject
    var viewModel: ViewModel
    @State private var animateGradient = false
    private let colorGr: [Color] = [.mainColorsGrayLightest.opacity(0.3),
                                    .mainColorsGrayLightest,
                                    .mainColorsGrayLightest]
    var body: some View {
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH1SB24322())
            .foregroundColor(.textSecondary)
            .padding(.vertical, 16)
            .padding(.leading, 20)
        
        ScrollView(.horizontal,showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(viewModel.latestPaymentsButtons.indices, id: \.self) { buttonVM in
                    
                    if viewModel.isAnimateState && buttonVM != 0 {
                        VStack(alignment: .center, spacing: 8) {
                            
                            Circle()
                                .fill(LinearGradient(colors: colorGr,
                                                     startPoint:  animateGradient ? .trailing : .leading,
                                                     endPoint:  .trailing ))
                                .frame(width: 56, height: 56)
                            
                            Spacer()
                                .frame(width: 80, height: 32)
                                .overlay13 {
                                    VStack(alignment: .center, spacing: 8) {
                                        LinearGradient(colors: colorGr,
                                                       startPoint:  animateGradient ? .trailing : .leading,
                                                       endPoint:  .trailing )
                                            .frame(width: 65, height: 8, alignment: .center)
                                            .cornerRadius(6)
                                            
                                        LinearGradient(colors: colorGr,
                                                       startPoint:  animateGradient ? .trailing : .leading,
                                                       endPoint:  .trailing )
                                            .frame(width: 45, height: 8, alignment: .center)
                                            .cornerRadius(6)
                                    }
                                }
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                animateGradient = true
                            }
                        }
                        .onDisappear { animateGradient = false }
                        
                    } else {
                        LatestPaymentButtonView(viewModel: viewModel.latestPaymentsButtons[buttonVM])
                    }
                }
                Spacer()
            }.padding(.leading, 8)
            
        }
    }
    
}

//MARK: - LatestPaymentButtonView

extension PTSectionLatestPaymentsView {
    
    struct LatestPaymentButtonView: View {
        
        let viewModel: ViewModel.LatestPaymentButtonVM
        
        var body: some View {
            Button(action: viewModel.action, label: {
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(height: 56)
                            .overlay13 {
                                
                                switch viewModel.avatar {
                                case let .image(image):
                                   
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(height: 56)
                                    
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
                            }
                    }
                    .overlay13(alignment: .topTrailing) {
                        if let topIcon = viewModel.topIcon {
                            topIcon
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    Text(viewModel.description)
                        .font(.textBodySR12160())
                        .lineLimit(2)
                        .foregroundColor(.textSecondary)
                        .frame(width: 80, height: 32, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            })
        }
    }

}

//MARK: default LatestPaymentButton by type

extension LatestPaymentData.Kind {
    
    var defaultName: String {
        
        switch self {
        case .country: return "За рубеж"
        case .phone: return "По телефону"
        case .service: return "Услуги ЖКХ"
        case .mobile: return "Услуги связи"
        case .internet: return "Услуги интернет"
        case .transport: return "Услуги Транспорта"
        case .taxAndStateService: return  "Госуслуги"
        }
    }
    
    var defaultIcon: Image {
        
        switch self {
        case .country: return .ic24Globe
        case .phone: return .ic24Smartphone
        case .service: return .ic24ZKX
        case .mobile: return .ic24Smartphone
        case .internet: return .ic24Tv
        case .transport: return .ic24Car
        case .taxAndStateService: return .ic24Emblem
        }
    }
}

//MARK: LatestPaymentButtonVM init

extension PTSectionLatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
    init(data: LatestPaymentData, model: Model, action: @escaping () -> Void) {
        
        func fullName(for phoneNumber: String?) -> String? {
            
            guard case .available = model.contactsPermissionStatus,
                  let phoneNumber = phoneNumber,
                  let contact = model.contact(for: phoneNumber)
            else { return nil }
            
            return contact.fullName
        }
                
        func avatar(for phoneNumber: String?) -> Self.Avatar? {
            
            guard case .available = model.contactsPermissionStatus,
                  let phoneNumber = phoneNumber,
                  let contact = model.contact(for: phoneNumber)
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
        
        switch (data.type, data) {
        case (.phone, let paymentData as PaymentGeneralData):
            
            self.avatar = avatar(for: paymentData.phoneNumber) ?? .icon(data.type.defaultIcon, .iconGray)
            self.topIcon = model.dictionaryBank(for: paymentData.bankId)?.svgImage.image
            self.description = fullName(for: paymentData.phoneNumber)
                                ?? (paymentData.phoneNumber.isEmpty
                                    ? data.type.defaultName : paymentData.phoneNumber)
            
        case (.country, let paymentData as PaymentCountryData):

            self.avatar = avatar(for: paymentData.phoneNumber)
                            ?? (!paymentData.shortName.isEmpty
                                ? .text(String(paymentData.shortName.first!).uppercased())
                                : .icon(data.type.defaultIcon, .iconGray))
            self.description = fullName(for: paymentData.phoneNumber)
                                ?? (paymentData.shortName.isEmpty
                                    ? data.type.defaultName : paymentData.shortName)
            self.topIcon = model.dictionaryCountry(for: paymentData.countryCode)?.svgImage?.image
                    
        case (.service, let paymentData as PaymentServiceData):
     
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
                    
        case (.transport, let paymentData as PaymentServiceData):
            
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
                    
        case (.internet, let paymentData as PaymentServiceData):
            
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
            
        case (.mobile, let paymentData as PaymentServiceData):
                
            self.avatar = avatar(for: paymentData.additionalList.first?.fieldValue)
                          ?? .icon(data.type.defaultIcon, .iconGray)
            if let phoneNumber = paymentData.additionalList.first?.fieldValue,
               !phoneNumber.isEmpty {
                self.description = fullName(for: phoneNumber) ?? phoneNumber
            } else {
                self.description = data.type.defaultName
            }
            self.topIcon = model.dictionaryAnywayOperator(for: paymentData.puref)?
                            .logotypeList.first?.svgImage?.image

                
        case (.taxAndStateService, let paymentData as PaymentServiceData):
           
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
            
        default: //error matching, init default
            self.avatar = .icon(data.type.defaultIcon, .iconGray)
            self.topIcon = nil
            self.description = data.type.defaultName
        }
        
        self.action = action
    }
            
}

//MARK: - Preview

struct PTSectionLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionLatestPaymentsView(viewModel: .sample)
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("Section LatestPayments")
    }
}
