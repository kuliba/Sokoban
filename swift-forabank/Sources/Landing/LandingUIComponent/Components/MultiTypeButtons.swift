//
//  MultiTypeButtons.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation
import Tagged
import SwiftUI
import Combine

public extension UILanding.Multi {
    
    struct TypeButtons: Equatable {
        
        let id: UUID
        let md5hash, backgroundColor, text: String
        let buttonText, buttonStyle: String
        let textLink: String?
        let action: Action?
        let detail: Detail?
        
        public struct Detail: Equatable {
            let groupId: GroupId
            let viewId: ViewId
            
            public init(groupId: GroupId, viewId: ViewId) {
                self.groupId = groupId
                self.viewId = viewId
            }
        }
        
        public struct Action: Equatable {
            
            let type: String
            let outputData: OutputData?
            
            public struct OutputData: Hashable {
                let tarif: Tarif
                let type: TypeData
                
                public init(tarif: Tarif, type: TypeData) {
                    self.tarif = tarif
                    self.type = type
                }
            }
            
            public init(type: String, outputData: OutputData?) {
                self.type = type
                self.outputData = outputData
            }
            
            enum ActionType: String {
                
                case goMain
                case openLink
                case orderCard
                case sticker
            }
            
            var actionType: ActionType? {
                
                return .init(rawValue: type)
            }
        }
        
        public init(
            id: UUID = UUID(),
            md5hash: String,
            backgroundColor: String,
            text: String,
            buttonText: String,
            buttonStyle: String,
            textLink: String?,
            action: Action?,
            detail: Detail?
        ) {
            self.id = id
            self.md5hash = md5hash
            self.backgroundColor = backgroundColor
            self.text = text
            self.buttonText = buttonText
            self.buttonStyle = buttonStyle
            self.textLink = textLink
            self.action = action
            self.detail = detail
        }
        
        public typealias GroupId = Tagged<_GroupId, String>
        public typealias ViewId = Tagged<_ViewId, String>
        public typealias Tarif = Tagged<_Tarif, Int>
        public typealias TypeData = Tagged<_TypeData, Int>

        public enum _GroupId {}
        public enum _ViewId {}
        public enum _Tarif {}
        public enum _TypeData {}
    }
}

extension MultiTypeButtonsView {
    
    final class ViewModel: ObservableObject {
        
        @Published private(set) var data: UILanding.Multi.TypeButtons
        @Published private(set) var images: [String: Image] = [:]

        private let selectDetail: SelectDetail
        private let action: (LandingEvent) -> Void
        private let orderCard: (Int, Int) -> Void

        init(
            data: UILanding.Multi.TypeButtons,
            images: [String: Image],
            selectDetail: @escaping SelectDetail,
            action: @escaping (LandingEvent) -> Void,
            orderCard: @escaping (Int, Int) -> Void
        ) {
            self.data = data
            self.images = images
            self.selectDetail = selectDetail
            self.action = action
            self.orderCard = orderCard
        }
        
        func image(byImageLink: String) -> Image? {
            
            return images[byImageLink]
        }
        
        func openUrl(for link: String?) {
            
            guard let link else { return }
            action(.card(.openUrl(link)))
        }
        
        func handler(for item: UILanding.Multi.TypeButtons) {
            
            if let actionValue = item.action {
                
                actionValue.actionType.map {
                    
                    switch $0 {
                    case .goMain:
                        action(.card(.goToMain))
                        
                    case .orderCard:
                        if let outputData = actionValue.outputData {
                            self.orderCard(outputData.tarif.rawValue, outputData.type.rawValue)
                        }
                        
                    case .sticker:
                        action(.sticker(.order))
                        
                    case .openLink:
                        break
                    }
                }
            } else if let detailDestination = item.detailDestination {
                
                selectDetail(detailDestination)
            }
        }
    }
}

extension UILanding.Multi.TypeButtons {
    
    func imageRequests() -> [ImageRequest] {
        
        return [ImageRequest.md5Hash(self.md5hash)]
    }
}

extension UILanding.Multi.TypeButtons {
    
    var detailDestination: DetailDestination? {
        
        detail.map {
            .init(
                groupID: .init($0.groupId.rawValue),
                viewID: .init($0.viewId.rawValue)
            )
        }
    }
}
