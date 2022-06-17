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
    @Published var sections: [MessagesHistorySectionView.ViewModel]
    @Published var sheet: Sheet?
    private var state: State
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    init( model: Model) {
        
        self.model = model
        self.sections = []
        self.state = .stating
        bind()
        model.action.send(ModelAction.Notification.Fetch.New.Request())
    }
    
    init( sections: [MessagesHistorySectionView.ViewModel], model: Model, state: State) {
        
        self.model = model
        self.sections = sections
        self.state = state
    }
    
    func createSections (with notifications: [NotificationData]) -> [MessagesHistorySectionView.ViewModel] {
        
        var keyArray = [Int]()
        var messages: [MessagesHistorySectionView.ViewModel] = []
        notifications.forEach { item in
            guard let section = item.groupIndex else { return }
            keyArray.append(section)
        }
        
        let uniqueKeyArray = Array(Set(keyArray))
        let sortedKeyArray = uniqueKeyArray.sorted(by: >)
        
        self.sections.removeAll()
        
        sortedKeyArray.forEach { key in
            
            var items = notifications.filter { $0.groupIndex == key }
            
            items.sort{ $0.sortIndex ?? 0 > $1.sortIndex ?? 0 }
            
            guard let section = items.map({$0.date}).first else { return }
            
            let message = MessagesHistorySectionView.ViewModel(title: DateFormatter.historyDateFormatter.string(from:section),
                                                                items: items)
            messages.append(message)
        }
        return messages
    }
    
    func bind() {
        
        model.notifications
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notifications in
                
                self.sections = createSections(with: notifications)
                bindSections(sections)
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ModelAction.Notification.Fetch.New.Response:
                    state = .normal
                case _ as ModelAction.Notification.Fetch.Next.Response:
                    state = .normal
                default:
                    break
                }
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MessagesHistoryViewModelAction.ScrolledToEnd:
                    
                    guard state == .normal else { return }
                    state = .updating
                    model.action.send(ModelAction.Notification.Fetch.Next.Request())
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    func bindSections(_ sections: [MessagesHistorySectionView.ViewModel]) {
            
            for section in sections {
                
                section.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in

                        switch action {
                        case let payload as MessagesHistorySectionViewAction.ItemTapped:
                            
                            guard let notificationData = model.notifications.value.first( where: {$0.id == payload.itemId})  else { return }
                            let notificationDetailViewModel = MessagesHistoryDetailViewModel(notificationData: notificationData)
                            sheet = .init(sheetType: .item(notificationDetailViewModel))
                            
                        default:
                            break
                        }
                    }.store(in: &bindings)
            }
        }
    
    struct ItemTapped: Action {
            let item: MessagesHistoryDetailViewModel
        }


}

extension MessagesHistoryViewModel {
    
    enum State {
        case stating
        case normal
        case updating
    }
}

enum MessagesHistoryViewModelAction {
    
    struct ScrolledToEnd: Action {}
    
    struct ItemTapped: Action {
        let item: MessagesHistoryDetailViewModel
    }
}

extension MessagesHistoryViewModel {
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case item(MessagesHistoryDetailViewModel)
        }
    }
}
