//
//  PushHistoryViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.06.2022.
//

import Foundation
import RealmSwift

struct PushHistoryViewModel {
    
    var sections: [PushHistoryModel] = []
    lazy var realm = try? Realm()
    var token: NotificationToken?
    var tempArray: Results <GetNotificationsModel>?
    var tempItems: Results <GetNotificationsCellModel>?
    
    mutating func addSections(_ complition: @escaping ([PushHistoryModel]) -> Void ) {
        
        tempArray = realm?.objects(GetNotificationsModel.self)
        tempItems = realm?.objects(GetNotificationsCellModel.self)
        
        /// Массив дат
        var dateArray = [String]()
        
        ///
        var tempItemsArray = [GetNotificationsCellModel]()
        
        /// Заполняем массив дат
        tempArray?.forEach{ getNotificationsModel in
            dateArray.append(getNotificationsModel.date ?? "")
        }
        
        /// Заполняем массив сообщений
        tempItems?.forEach { item in
            tempItemsArray.append(item)
        }
        
        /// Сортируем массив по убыванию
        
        dateArray = Array(Set(dateArray))
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "dd.MM.yyyy"
        let dates = dateArray.compactMap { isoFormatter.date(from: $0) }

        let sortedDates = dates.sorted { $0 > $1 }
        let dateStrings = sortedDates.compactMap { isoFormatter.string(from: $0)}
        
        dateStrings.forEach { date in
            
            var items = tempItemsArray.filter { dateFormater($0.date ?? "", "dd.MM.yyyy") == date  }
            items = items
                    .sorted(by: {$0.id ?? "" > $1.id ?? ""})
            
            items = items.uniqueValues(value: {$0.date})
            
            let itemModel: [PushHistoryModel.PushHistoryItems] = items.map {PushHistoryModel.PushHistoryItems(with: $0)}
            
            sections.append(PushHistoryModel(sections: date, items: itemModel))
            
        }
        
        complition(sections)
    }
    
    
    func dateFormater(_ string: String, _ formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = dateFormatter.date(from: string)!
        
        let d = DateFormatter()
        d.locale = Locale(identifier: "ru_RU")
        d.dateFormat = formatter
        
        let stringDate = d.string(from: date)
        return stringDate
    }
}

extension Array
  {
     func uniqueValues<V:Equatable>( value:(Element)->V) -> [Element]
     {
        var result:[Element] = []
        for element in self
        {
            if !result.contains(where: { value($0) == value(element) })
           { result.append(element) }
        }
        return result
     }
  }
