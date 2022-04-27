//
//  MessagesHistoryViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI
import Combine

class MessagesHistoryViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    @Published var sections: [MessagesHistorySectionView]
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    init( model: Model) {
        self.model = model
        self.sections = []
        bind()
    }
    
    init( sections: [MessagesHistorySectionView]) {
        
        self.model = Model.emptyMock
        self.sections = sections
    }
    
    func createSections (with notifications: [NotificationData]) {
        
        
        var dic: [String: [NotificationData]] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        
        notifications.forEach { notificationData in
            
            if var val = dic[formatter.string(from: notificationData.date)] {
                val.append(notificationData)
                dic[formatter.string(from: notificationData.date)] = val
            } else {
                dic[formatter.string(from: notificationData.date)] = [notificationData]
            }
        }
        
        print(dic)
        
        let sections = [
            MessagesHistorySectionView.init(viewModel: .init(section: "25 агуста, ср",
                                                             items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                                                                     MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
                                                                                    ]))
        ]
        
        self.sections = sections
    }
    
    func bind() {
        model.notifications
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notifications in
                
                createSections(with: notifications)
                
            }.store(in: &bindings)
    }
}
