//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import Combine
import SwiftUI

class PaymentsTransfersViewModel: ObservableObject {
    
    @Published
    var latestPaymentsButtons: [LatestPaymentButtonVM]
    
    let payGroupButtons: [PayGroupButtonVM]
    let transferButtons: [TransferButtonVM]
    
    let latestPaymentsSectionTitle: String
    let transfersSectionTitle: String
    let paySectionTitle: String
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model) {
        
        self.latestPaymentsSectionTitle = "Платежи"
        self.transfersSectionTitle = "Перевести"
        self.paySectionTitle = "Оплатить"
        
        self.payGroupButtons = Self.payGoupButtonsData
        self.transferButtons = Self.transferButtonsData
        self.latestPaymentsButtons = Self.templateButtonData
        
        self.model = model
        self.model.action.send(ModelAction.LatestPayments.List.Requested())
        
        bind()
    }
    
    init(latestPaymentsSectionTitle: String,
         transfersSectionTitle: String,
         paySectionTitle: String,
         latestPaymentsButtons: [LatestPaymentButtonVM],
         transferButtons: [TransferButtonVM],
         payGroupButtons: [PayGroupButtonVM],
         model: Model) {
        
        self.latestPaymentsSectionTitle = latestPaymentsSectionTitle
        self.transfersSectionTitle = transfersSectionTitle
        self.paySectionTitle = paySectionTitle
        
        self.payGroupButtons = payGroupButtons
        self.transferButtons = transferButtons
        self.latestPaymentsButtons = latestPaymentsButtons
        self.model = model
    }
    
    func bind() {
        // data updates from model
        model.latestPayments
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] latestPayments in
                
                withAnimation {
                    
                    if !latestPayments.isEmpty {
                        
                        self.latestPaymentsButtons = Self.templateButtonData
                        //TODO: handle model -> viewModel
                        
                    } else {
                        
                        self.latestPaymentsButtons = Self.templateButtonData
                    }
                 
                }
    
            }.store(in: &bindings)
        
    }
}

extension PaymentsTransfersViewModel {
  
    struct LatestPaymentButtonVM: Identifiable {
           
           let id = UUID()
           let image: ImageType
           let topIcon: Image?
           let description: String
           let action: () -> Void

           enum ImageType {
             case image(Image)
             case text(String)
             case icon(Image, Color)
           }
        
    }
    
    struct PayGroupButtonVM: Identifiable {
        var id: String { title }
        
        let title: String
        let image: String
        let action: () -> Void
    }
    
    struct TransferButtonVM: Identifiable {
        var id: String { title }
        
        let title: String
        let image: String
        let action: () -> Void
    }
    
    static let templateButtonData: [LatestPaymentButtonVM] = {
        [
            .init(image: .icon(Image("ic24Star"), .iconBlack),
                topIcon: nil,
                description: "Шаблоны и автоплатежи",
                action: {})
        ]
    }()
    
    static let payGoupButtonsData: [PayGroupButtonVM] = {
        [
        .init(title: "Оплата по QR", image: "ic24BarcodeScanner2", action: {}),
        .init(title: "Мобильная связь", image: "ic24Smartphone", action: {}),
        .init(title: "Услуги ЖКХ", image: "ic24Bulb", action: {}),
        .init(title: "Интернет, ТВ", image: "ic24Tv", action: {}),
        .init(title: "Штрафы", image: "ic24Car", action: {}),
        .init(title: "Госуслуги", image: "ic24Emblem", action: {}),
        .init(title: "Соцсети, игры, карты", image: "ic24Gamepad", action: {}),
        .init(title: "Охранные системы", image: "ic24Key", action: {}),
        .init(title: "Прочее", image: "ic24ShoppingCart", action: {})
        ]
    }()
    
    static let transferButtonsData: [TransferButtonVM] = {
        [
        .init(title: "По номеру\nтелефона", image: "ic48Telephone", action: {}),
        .init(title: "Между\nсвоими", image: "ic48BetweenTheir", action: {}),
        .init(title: "За рубеж\nи по РФ", image: "ic48Abroad", action: {}),
        .init(title: "На другую\nкарту ", image: "ic48AnotherCard", action: {}),
        .init(title: "По\nреквизитaм", image: "ic48BankDetails", action: {})
        ]
    }()
    
}
