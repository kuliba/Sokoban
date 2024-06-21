//
//  ListHorizontalRectangleLimitsView.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct ListHorizontalRectangleLimitsView: View {
    
    @ObservedObject var model: ViewModel
    let config: Config
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                ForEach(model.data.list, content: itemView)
            }
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
    }
    
    private func itemView (
        item: Item
    ) -> some View {
        
        ItemView(
            item: item,
            makeIcon: model.makeIconView,
            makeLimit: model.makeLimit,
            config: config
        )
        .gesture(
            TapGesture()
                .onEnded {
                    model.itemAction(item: item)
                }
        )
    }
    
    typealias Item = UILanding.List.HorizontalRectangleLimits.Item
    typealias Config = UILanding.List.HorizontalRectangleLimits.Config
}

extension ListHorizontalRectangleLimitsView {
    
    struct ItemView: View {
        
        let item: UILanding.List.HorizontalRectangleLimits.Item
        let makeIcon: LandingView.MakeIconView
        let makeLimit: LandingView.MakeLimit
        
        let config: Config
        
        var body: some View {
            
            ZStack {
                config.colors.background
                    .ignoresSafeArea()
                    .cornerRadius(config.cornerRadius)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        ZStack {
                            
                            Capsule(style: .circular)
                                .frame(width: config.size.icon * 2, height: config.size.icon * 2)
                                .foregroundColor(.white)
                            
                            makeIcon(item.md5hash)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: config.size.icon, height: config.size.icon)
                        }
                        
                        Text(item.title)
                            .lineLimit(2)
                            .foregroundColor(config.colors.title)
                    }
                    .padding(.horizontal, config.paddings.horizontal)
                    
                    ForEach(item.limits, id: \.id) { itemView(limit: $0)
                        if $0 != item.limits.last {
                            
                            HorizontalDivider(color: config.colors.divider)
                                .padding(.vertical, 0)
                        }
                    }
                    .padding(.horizontal, config.paddings.horizontal)
                }
            }
            .frame(width: config.size.width, height: config.size.height)
        }
        
        private func itemView(
            limit: UILanding.List.HorizontalRectangleLimits.Item.Limit
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                Text(limit.title)
                    .font(.caption)
                    .foregroundColor(config.colors.subtitle)
                
                limitView(limit: makeLimit(limit.id), color: limit.color)
            }
        }
        
        private func limitView(
            limit: LimitValues?,
            color: Color
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(value(limit: limit?.value))
                        .font(.subheadline)
                        .foregroundColor(config.colors.title)
                    Text(limit?.currency ?? "")
                        .font(.subheadline)
                        .foregroundColor(config.colors.title)
                    circleLimit(
                        limit: limit,
                        mainColor: color,
                        currentColor: config.colors.arc,
                        spent: limit?.spentPercent ?? .noSpent)
                }
            }
        }
        
        @ViewBuilder
        private func circleLimit(
            limit: LimitValues?,
            mainColor: Color,
            currentColor: Color,
            spent: LimitValues.Spent
        ) -> some View {
            
            let startCurrent = 270.0
            let startMain = 255.0
            
            switch spent {
            case .noSpent:
                ZStack {
                    Arc(startAngle: .degrees(startCurrent), endAngle: .degrees(startCurrent + 360), clockwise: false)
                        .stroke(mainColor, lineWidth: 4)
                        .frame(width: 12, height: 12)
                }
                .frame(width: config.size.icon, height: config.size.icon)
                
            case .spentEverything:
                ZStack {
                    Arc(startAngle: .degrees(startCurrent), endAngle: .degrees(startCurrent + 360), clockwise: false)
                        .stroke(currentColor, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
                .frame(width: config.size.icon, height: config.size.icon)
                
            case let .spent(currentAngle):
                ZStack {
                    Arc(startAngle: .degrees(currentAngle + startCurrent + 15), endAngle: .degrees(startMain), clockwise: false)
                        .stroke(mainColor, lineWidth: 4)
                        .frame(width: 12, height: 12)
                    Arc(startAngle: .degrees(startCurrent), endAngle: .degrees(currentAngle + startCurrent), clockwise: false)
                        .stroke(currentColor, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
                .frame(width: config.size.icon, height: config.size.icon)
            }
        }
        
        struct Arc: Shape {
            var startAngle: Angle
            var endAngle: Angle
            var clockwise: Bool
            
            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
                
                return path
            }
        }
        
        // возможно стоит перенести в основной таргет
        
        private func value(limit: Decimal?) -> String {
            
            if let limit {
                return "\(limit)"
            }
            else { return "Не установлен" }
        }
    }
}

struct ListHorizontalRectangleLimitsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ListHorizontalRectangleLimitsView(
            model: defaultValue,
            config: .default)
        
    }
    static let defaultValue: ListHorizontalRectangleLimitsView.ViewModel = .init(
        data:
                .init(
                    list: [
                        .init(
                            action: .init(type: "action"),
                            limitType: "Debit",
                            md5hash: "1",
                            title: "Платежи и переводы",
                            limits: [
                                .init(
                                    id: "1",
                                    title: "Осталось сегодня",
                                    color: Color(red: 28/255, green: 28/255, blue: 28/255)),
                                .init(
                                    id: "2",
                                    title: "Осталось в этом месяце",
                                    color: Color(red: 255/255, green: 54/255, blue: 54/255)),
                                
                            ]),
                        .init(
                            action: .init(type: "action"),
                            limitType: "Credit",
                            md5hash: "md5Hash",
                            title: "Снятие наличных",
                            limits: [
                                .init(
                                    id: "3",
                                    title: "Осталось сегодня",
                                    color: Color(red: 28/255, green: 28/255, blue: 28/255)),
                                .init(
                                    id: "4",
                                    title: "Осталось в этом месяце",
                                    color: Color(red: 255/255, green: 54/255, blue: 54/255)),
                            ])
                    ]),
        action: { _ in }
        ,
        makeIconView: {
            if $0 == "1" {
                .init(
                    image: .flag,
                    publisher: Just(.percent).eraseToAnyPublisher()
                ) } else {
                    .init(
                        image: .percent,
                        publisher: Just(.flag).eraseToAnyPublisher()
                        
                    )}
        },
        makeLimit: {
            switch $0 {
            case "1":
                return .init(currency: "₽", currentValue: 100, name: "1", value: 100)
            case "2":
                return .init(currency: "$", currentValue: 100, name: "1", value: 200)
            case "3":
                return .init(currency: "ђ", currentValue: 30, name: "1", value: 300)
            case "4":
                return .init(currency: "§", currentValue: 30, name: "1", value: 400)
            default:
                return .init(currency: "$", currentValue: 200, name: "2", value: 400)
            }
        })
}

extension LimitValues {
    
    enum Spent {
        
        case noSpent
        case spentEverything
        case spent(Double)
    }
    
    // 270->595 325 -> 100%
    /*
     
     270 - 0
     595 - 100
     cur - x
     
     435 - 50%
     */
    var spentPercent: Spent {
        
        let balance = value - currentValue
        
        switch balance {
        case 0:
            return .spentEverything
            
        case value:
            return .noSpent
            
        default:
            let currentPercent = Double(truncating: (currentValue/value * 100.00) as NSNumber)
            return  .spent(ceil(325/100 * currentPercent))
        }
    }
}

