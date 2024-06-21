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
            config: config,
            spentConfig: model.spentConfig
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

extension Spent {
    
    static func spentPercent(
        limit: LimitValues?,
        interval: CGFloat
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
            return .spent(ceil((360 - interval * 2)/100 * currentPercent))
        }
    }
}

extension ListHorizontalRectangleLimitsView {
    
    struct ItemView: View {
        
        let item: UILanding.List.HorizontalRectangleLimits.Item
        let makeIcon: LandingView.MakeIconView
        let makeLimit: LandingView.MakeLimit
        
        let config: Config
        let spentConfig: SpentConfig

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
                    
                    ForEach(item.limits, id: \.id) { 
                        itemView(limit: $0)
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
                        spent: Spent.spentPercent(limit: limit, interval: spentConfig.interval))
                    .frame(width: config.size.icon, height: config.size.icon)
                }
            }
        }
        
        @ViewBuilder
        private func circleLimit(
            limit: LimitValues?,
            mainColor: Color,
            currentColor: Color,
            spent: Spent
        ) -> some View {
            
            switch spent {
            case .noSpent:
                circle(mainColor, spentConfig.mainWidth, spentConfig.mainArcSize)
                
            case .spentEverything:
                circle(currentColor, spentConfig.spentWidth, spentConfig.size)
                
            case let .spent(currentAngle):
                ZStack {
                    
                    arc(start: currentAngle + spentConfig.interval, end: spentConfig.startMainAngle, mainColor, spentConfig.mainWidth, spentConfig.mainArcSize)
                    arc(start: spentConfig.startSpentAngle, end: currentAngle, currentColor, spentConfig.spentWidth, spentConfig.size)
                }
            }
        }
        
        private func arc(
            start: Double,
            end: Double,
            _ color: Color,
            _ lineWidth: CGFloat,
            _ width: CGFloat
        ) -> some View {
            Arc(
                startAngle: .degrees(start),
                endAngle: .degrees(end),
                clockwise: false
            )
                .stroke(color, lineWidth: lineWidth)
                .frame(width: width, height: width)
        }
        
        private func circle(
            _ color: Color,
            _ lineWidth: CGFloat,
            _ width: CGFloat
        ) -> some View {
            Circle()
                .stroke(
                    color,
                    lineWidth: lineWidth
                )
                .frame(width: width, height: width)
        }
        
        struct Arc: Shape {
            
            let startAngle: Angle
            let endAngle: Angle
            let clockwise: Bool
            
            func path(in rect: CGRect) -> Path {
                
                var path = Path()
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: clockwise)
                
                return path
            }
        }
        
        // TODO: перенести в основной таргет + добавить все case
        
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
        action: { _ in },
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
                return .init(currency: "₽", currentValue: 90, name: $0, value: 100)
            case "2":
                return .init(currency: "$", currentValue: 199.99, name: $0, value: 200)
            case "3":
                return .init(currency: "ђ", currentValue: 300, name: $0, value: 300)
            case "4":
                return .init(currency: "§", currentValue: 0, name: $0, value: 400)
            default:
                return .init(currency: "$", currentValue: 0, name: "5", value: 400)
            }
        })
}
