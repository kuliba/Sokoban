//
//  ProductDetailsState.swift
//
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Foundation

public struct ProductDetailsState: Equatable {
    
    public let accountDetails: [ListItem]
    public let cardDetails: [ListItem]
    public var status: ProductDetailsStatus?
    public var showCheckBox: Bool
    public var title: String
    public var detailsState: DetailsState
    
    var dataForShare: [String]
    
    public init(
        accountDetails: [ListItem],
        cardDetails: [ListItem],
        status: ProductDetailsStatus? = nil,
        showCheckBox: Bool = false,
        title: String = "Реквизиты счета и карты",
        detailsState: DetailsState = .initial,
        dataForShare: [String] = []
    ) {
        self.accountDetails = accountDetails
        self.cardDetails = cardDetails
        self.status = status
        self.showCheckBox = showCheckBox
        self.title = title
        self.detailsState = detailsState
        self.dataForShare = dataForShare
    }
    
    public mutating func updateDetailsStateByTap(_ id: DocumentItem.ID) {
        
        switch id {
            
        case .number:
            if detailsState == .needShowNumber { detailsState = .initial }
            else { detailsState = .needShowNumber }
        case .cvv:
            if detailsState == .needShowCvv { detailsState = .initial }
            else { detailsState = .needShowCvv }
        default:
            break
        }
    }
    
    mutating func updateShareData(_ shareData: ShareData) {
        
        let values = {
            switch shareData {
            case .needAddAccountInfo:
                return accountDetails.map { $0.currentValueString }
                
            case .needAddCardInfo:
                return cardDetails.map { $0.currentValueString }
            }
        }()
        
        shareData.needAdd ?
        dataForShare.append(contentsOf: values) :
        dataForShare.removeObjectsInArray(array: values)
    }
    
    func copyValues() -> [String] {
        return dataForShare
    }
    
    mutating func allVallues() -> [String] {
        
        updateShareData(.needAddAccountInfo(true))
        updateShareData(.needAddCardInfo(true))
        return dataForShare
    }
    
    mutating func cleanDataForShare() {
        dataForShare.removeAll()
    }
    
    enum ShareData {
        
        case needAddAccountInfo(Bool)
        case needAddCardInfo(Bool)
        
        var needAdd: Bool {
            
            switch self {
            case let .needAddAccountInfo(needAdd):
                return needAdd
            case let .needAddCardInfo(needAdd):
                return needAdd
            }
        }
    }
}

public enum DetailsState {
    
    case initial
    case needShowNumber
    case needShowCvv
}

extension Array where Element: Equatable {
    
    mutating func removeObject(object: Element) {
        
        if let index = self.firstIndex(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        
        for object in array {
            self.removeObject(object: object)
        }
    }
}
