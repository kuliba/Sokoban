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
                Color.init(hex: "#F6F6F7")
                    .ignoresSafeArea()
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        ZStack {
                            
                            Capsule(style: .circular)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            makeIcon(item.md5hash)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        
                        Text(item.title)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 12)
                    
                    ForEach(item.limits, id: \.id) { itemView(limit: $0)
                        if $0 != item.limits.last {
                            Divider()
                                .padding(.vertical, 0)
                        }
                    }
                    .padding(.horizontal, 12)

                }
            }
            .frame(width: 180, height: 176)
        }
        
        private func itemView(
            limit: UILanding.List.HorizontalRectangleLimits.Item.Limit
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                Text(limit.title)
                    .font(.caption)
                
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
                    Text(limit?.currency ?? "")
                        .font(.subheadline)
                    
                    circleLimit(limit: limit, mainColor: color)
                        .frame(width: 20, height: 20)
                    
                }
            }
        }
        
        private func circleLimit(
            limit: LimitValues?,
            mainColor: Color,
            currentColor: Color = .init(hex: "#999999")
        ) -> some View {
            
            ZStack {
                Arc(startAngle: .degrees(-90), endAngle: .degrees(15), clockwise: true)
                    .stroke(mainColor, lineWidth: 4)
                    .frame(width: 12, height: 12)
                Arc(startAngle: .degrees(0), endAngle: .degrees(-75), clockwise: true)
                    .stroke(currentColor, lineWidth: 2)
                    .frame(width: 12, height: 12)
            }
            .frame(width: 20, height: 20)
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
                                color: .init(hex: "#1C1C1C")),
                            .init(
                                id: "2",
                                title: "Осталось в этом месяце",
                                color: .init(hex: "#FF3636")),
                            
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
                                color: .init(hex: "#1C1C1C")),
                            .init(
                                id: "4",
                                title: "Осталось в этом месяце",
                                color: .init(hex: "#FF3636")),
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
        return .init(currency: "₽", currentValue: 10, name: "1", value: 100)
    case "2":
        return .init(currency: "$", currentValue: 20, name: "1", value: 200)
    case "3":
        return .init(currency: "ђ", currentValue: 30, name: "1", value: 300)
    case "4":
        return .init(currency: "§", currentValue: 30, name: "1", value: 400)
    default:
        return .init(currency: "$", currentValue: 200, name: "2", value: 400)
    }
        })
}

// TODO: only for debug

private extension Color {
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
