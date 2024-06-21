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
            
            public let id: UUID
            let action: Action
            let limitType: String
            let md5hash: String
            let title: String
            let limits: [Limit]
            
            public init(id: UUID = UUID(), action: Action, limitType: String, md5hash: String, title: String, limits: [Limit]) {
                self.id = id
                self.action = action
                self.limitType = limitType
                self.md5hash = md5hash
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Equatable {
                
                let id: String
                let title: String
                let color: Color
                
                public init(id: String, title: String, color: Color) {
                    self.id = id
                    self.title = title
                    self.color = color
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
        let makeLimit: LandingView.MakeLimit
        private let action: (LandingEvent) -> Void
        let spentConfig: SpentConfig = .init()

        init(
            data: HorizontalList,
            action: @escaping (LandingEvent) -> Void,
            makeIconView: @escaping LandingView.MakeIconView,
            makeLimit: @escaping LandingView.MakeLimit
        ) {
            self.data = data
            self.action = action
            self.makeIconView = makeIconView
            self.makeLimit = makeLimit
        }
        
        func itemAction(
            item: HorizontalList.Item
        ) {
            // TODO: добавить корректный
            print("tap \(item.limitType)")
            action(.card(.goToMain))
        }
        
        func spentPercent(
            limit: LimitValues?
        ) -> Spent {
            
            guard let limit else { return .noSpent }
            
            let balance = limit.value - limit.currentValue
            
            switch balance {
            case 0:
                return .spentEverything
                
            case limit.value:
                return .noSpent
                
            default:
                let currentPercent = min(Double(truncating: (limit.currentValue/limit.value * 100.00) as NSNumber), 99.6)
                return .spent(ceil((360 - spentConfig.interval * 2)/100 * currentPercent))
            }
        }
    }
}

enum Spent {
    
    case noSpent
    case spentEverything
    case spent(Double)
}

struct SpentConfig {
    
    let startMainAngle: Double
    let startSpentAngle: Double
    let interval: Double
    let size: CGFloat
    let mainWidth: CGFloat
    let spentWidth: CGFloat
    
    init(
        startSpentAngle: Double = 270,
        interval: Double = 15,
        size: CGFloat = 14,
        mainWidth: CGFloat = 4
    ) {
        self.startMainAngle = startSpentAngle - interval
        self.startSpentAngle = startSpentAngle
        self.interval = interval
        self.size = size
        self.mainWidth = mainWidth
        self.spentWidth = mainWidth/2 
    }
    
    var mainArcSize: CGFloat {
        size - spentWidth
    }
}
