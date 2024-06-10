//
//  ListHorizontalRectangleLimits.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

extension UILanding.List {
    
    public struct HorizontalRectangleLimits: Identifiable, Equatable {
        
        public let id: UUID

        let list: [Item]
        
        public init(id: UUID = UUID(), list: [Item]) {
            self.id = id
            self.list = list
        }

        public struct Item: Identifiable, Equatable {
            
            public var id: String { action.type }
            let action: Action
            let limitType: String
            let md5hash: String
            let title: String
            let limits: [Limit]
            
            public init(action: Action, limitType: String, md5hash: String, title: String, limits: [Limit]) {
                self.action = action
                self.limitType = limitType
                self.md5hash = md5hash
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Equatable {
                
                let id: String
                let title: String
                let colorHEX: String
                
                public init(id: String, title: String, colorHEX: String) {
                    self.id = id
                    self.title = title
                    self.colorHEX = colorHEX
                }
            }
            
            public struct Action: Hashable {
                
                let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }
        }
    }
}

extension ListHorizontalRectangleLimitsView {
    
    final class ViewModel: ObservableObject {
        
        typealias HorizontalList = UILanding.List.HorizontalRectangleLimits
        
        @Published private(set) var data: HorizontalList
                
        let makeIconView: LandingView.MakeIconView
        
        init(
            data: HorizontalList,
            makeIconView: @escaping LandingView.MakeIconView
        ) {
            self.data = data
            self.makeIconView = makeIconView
        }
    }
}
