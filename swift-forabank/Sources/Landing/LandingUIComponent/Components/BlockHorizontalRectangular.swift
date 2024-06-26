//
//  BlockHorizontalRectangular.swift
//  
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

extension UILanding {
    
    public struct BlockHorizontalRectangular: Identifiable, Equatable {
        
        public let id: UUID

        let list: [Item]
        
        public init(id: UUID = UUID(), list: [Item]) {
            self.id = id
            self.list = list
        }

        public struct Item: Identifiable, Equatable {
            
            public var id: String { limitType }
            let limitType: String
            let description: String
            let title: String
            let limits: [Limit]
            
            public init(limitType: String, description: String, title: String, limits: [Limit]) {
                self.limitType = limitType
                self.description = description
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Equatable {
                
                let id: String
                let title: String
                let md5hash: String
                let text: String
                let maxSum: Decimal

                public init(id: String, title: String, md5hash: String, text: String, maxSum: Decimal) {
                    self.id = id
                    self.title = title
                    self.md5hash = md5hash
                    self.text = text
                    self.maxSum = maxSum
                }
            }
        }
    }
}

extension BlockHorizontalRectangularView {
    
    final class ViewModel: ObservableObject {
        
        typealias HorizontalList = UILanding.BlockHorizontalRectangular
        
        @Published private(set) var data: HorizontalList
                
        private let action: (LandingEvent) -> Void

        init(
            data: HorizontalList,
            action: @escaping (LandingEvent) -> Void
        ) {
            self.data = data
            self.action = action
        }
        
        func itemAction(
            item: HorizontalList.Item
        ) {
            // TODO: добавить корректный
            print("tap \(item.limitType)")
        }
    }
}
