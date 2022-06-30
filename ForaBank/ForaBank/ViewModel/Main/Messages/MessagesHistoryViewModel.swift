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
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var sections: [MessagesHistorySectionView.ViewModel]
    @Published var sheet: Sheet?
    
    private var state: State
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    init(navigationBar: NavigationBarView.ViewModel, sections: [MessagesHistorySectionView.ViewModel], state: State, model: Model = .emptyMock) {
        
        self.navigationBar = navigationBar
        self.sections = sections
        self.state = state
        self.model = model
    }
    
    init( model: Model, dismissAction: @escaping () -> Void) {
        
        
        self.sections = []
        self.state = .stating
        self.navigationBar = .init(title: "Центр уведомлений",
                                   leftButtons: [ NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: dismissAction)])
        self.model = model
        
        bind()
        model.action.send(ModelAction.Notification.Fetch.New.Request())
    }

    private func bind() {
        
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
    
    func createSections(with notifications: [NotificationData]) -> [MessagesHistorySectionView.ViewModel] {
        
        var keyArray = [Int]()
        var messages: [MessagesHistorySectionView.ViewModel] = []
        notifications.forEach { item in
            let section = item.date.groupDayIndex
            keyArray.append(section)
        }
        
        let uniqueKeyArray = Array(Set(keyArray))
        let sortedKeyArray = uniqueKeyArray.sorted(by: >)
        
        self.sections.removeAll()
        
        sortedKeyArray.forEach { key in
            
            var items = notifications.filter { $0.date.groupDayIndex == key }
            
            items.sort{ $0.date > $1.date }
            
            guard let section = items.map({$0.date}).first else { return }
            
            let message = MessagesHistorySectionView.ViewModel(title: DateFormatter.historyShortDateFormatter.string(from:section),
                                                               items: items)
            messages.append(message)
        }
        
        return messages
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
