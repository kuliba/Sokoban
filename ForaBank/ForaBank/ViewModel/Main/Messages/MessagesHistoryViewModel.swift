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
    
    init( model: Model, closeAction: @escaping () -> Void ) {
        
        self.sections = Self.reduce(sections: [], with: model.notifications.value)
        self.state = .stating
        self.navigationBar = .init(title: "Центр уведомлений",
                                   leftItems: [ NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: closeAction)])
        self.model = model
        
        bind()
        model.action.send(ModelAction.Notification.Fetch.New.Request())
    }

    private func bind() {
        
        model.notifications
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notifications in
                
                withAnimation {
                    sections = Self.reduce(sections: sections, with: notifications)
                }
                
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
                    
                case _ as MessagesHistoryViewModelAction.ViewDidAppear:
                    model.action.send(ModelAction.Notification.Transition.ClearBadges())

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
                        
                        sheet = .init(sheetType: .item(notificationDetailViewModel, handleLink: handleLink))
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
    }
    
    static func reduce(sections: [MessagesHistorySectionView.ViewModel], with notifications: [NotificationData]) -> [MessagesHistorySectionView.ViewModel] {
        
        //TODO: implement update existing sections
        
        let formatter = DateFormatter.historyShortDateFormatter
        var updated = [MessagesHistorySectionView.ViewModel]()
        let groupDayIndexes = Self.groupDayIndexes(for: notifications)
        
        for index in groupDayIndexes {
            
            let items = notifications.filter { $0.date.groupDayIndex == index }
            guard items.count > 0 else {
                continue
            }
            
            let itemsSorted = items.sorted(by: { $0.date > $1.date })
            let sectionDate = itemsSorted[0].date
            let sectionTitle = formatter.string(from: sectionDate)
            
            let section = MessagesHistorySectionView.ViewModel(id: index, title: sectionTitle, items: itemsSorted)
        
            updated.append(section)
        }
        
        return updated
    }
    
    static func groupDayIndexes(for notifications: [NotificationData]) -> [Int] {
        
        let indexes = notifications.map({ $0.date.groupDayIndex })
        let uniqueIndexes = Array(Set(indexes))
        let sortedIndexes = uniqueIndexes.sorted(by: >)
        
        return sortedIndexes
    }
    
    func handleLink(_ url: URL) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let idItem = components.queryItems?.first(where: { $0.name == "id" }),
              let bankId = idItem.value else {
            
            return
        }
        
        model.action.send(ModelAction.Consent.Me2MeDebit.Request(bankid: bankId))
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
    
    struct ViewDidAppear: Action {}

}

extension MessagesHistoryViewModel {
    
    struct Sheet: BottomSheetCustomizable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case item(MessagesHistoryDetailViewModel, handleLink: (URL) -> Void)
        }
    }
}
