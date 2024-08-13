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
    
    let state: ListHorizontalRectangleLimitsState
    let event: (ListHorizontalRectangleLimitsEvent) -> Void
    let factory: Factory
    let config: Config

    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                ForEach(state.list.list, content: itemView)
            }
        }
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: destinationView
        )
        
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
    }
    
    @ViewBuilder
    private func destinationView(
        destination: ListHorizontalRectangleLimitsState.Destination
    ) -> some View {
        
        switch destination {
        case let .settingsView(viewModel, subtitle, limitType):
            
            VStack {
                NavigationBar(
                    backAction: { event(.dismissDestination) },
                    title: viewModel.navigationTitle(),
                    subtitle: subtitle,
                    config: config.navigationBarConfig
                )

                LandingWrapperView(
                    viewModel: viewModel,
                    updateSaveButtonAction: { updateSaveButtonAction(viewModel: viewModel) }
                )
                    .frame(maxHeight: .infinity)
                    .alert(
                        item: .init(
                            get: { state.alert?.text },
                            set: { _ in }
                        ),
                        content: alertContent
                    )
                
                if state.editEnableFor(limitType) {
                    Button(action: {
                        UIApplication.shared.endEditing()
                        event(.saveLimits(viewModel.newLimitsValue))
                    }) {
                        ZStack {
                            if state.saveButtonEnable {
                                Color(red: 255/255, green: 54/255, blue: 54/255)

                            } else {
                                Color(red: 211/255, green: 211/255, blue: 211/255)
                            }
                            Text("Сохранить")
                                .padding()
                        }
                    }
                    .foregroundColor(.white)
                    .cornerRadius(config.cornerRadius)
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    .padding(.vertical, config.paddings.vertical)
                    .disabled(!state.saveButtonEnable)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .padding(.bottom)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
        
    private func alertContent(_ message: String) -> Alert {
        
        return .init(
            title: Text("Ошибка"),
            message: Text(message)
        )
    }

    private func itemView (
        item: Item
    ) -> some View {
        
        ItemView(
            item: item,
            factory: factory,
            limitsLoadingStatus: state.limitsLoadingStatus,
            config: config
        )
        .gesture(
            TapGesture()
                .onEnded {
                    event(.buttonTapped(.init(limitType: item.limitType, action: item.action.type)))
                }
        )
    }
    
    private func updateSaveButtonAction(viewModel: LandingWrapperViewModel) {
        
        let newValueMoreThenMaxValue: Bool  = {
            
            if case let .success(landing) = viewModel.state {
                
                return landing?.blockHorizontalRectangular? .newValueMoreThenMaxValue(viewModel.newLimitsValue) ?? false
            }
            
            return false
        }()
        
        event(.limitChanging(viewModel.newLimitsValue, newValueMoreThenMaxValue))
    }
}

extension ListHorizontalRectangleLimitsView {
    
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Factory = ViewFactory
    typealias Config = UILanding.List.HorizontalRectangleLimits.Config
    typealias Item = UILanding.List.HorizontalRectangleLimits.Item
}

extension Spent {
    
    static func spentPercent(
        limit: LimitValues?,
        interval: CGFloat,
        startAngle: CGFloat
    ) -> Spent {
        
        guard let limit else { return .noSpent }
        
        let balance = limit.value - limit.currentValue
        
        switch balance {
        case _ where balance <= 0:
            return .spentEverything
            
        case limit.value:
            return .noSpent
            
        default:
            let currentPercent = min(Double(truncating: (limit.currentValue/limit.value * 100.00) as NSNumber), 99.6)
            return .spent(ceil((360 - interval * 2)/100 * currentPercent) + startAngle)
        }
    }
}

extension ListHorizontalRectangleLimitsView {
    
    struct ItemView: View {
        
        let halfScreenWidth: CGFloat = UIScreen.main.bounds.width/2

        let item: UILanding.List.HorizontalRectangleLimits.Item
        let factory: Factory
        let limitsLoadingStatus: LimitsLoadingStatus
        let config: Config
        let spentConfig: SpentConfig = .init()
        
        var body: some View {
            
            ZStack {
                config.colors.background
                    .ignoresSafeArea()
                    .cornerRadius(config.cornerRadius)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        ZStack {
                            
                            Capsule(style: .circular)
                                .frame(widthAndHeight: config.sizes.icon * 2)
                                .foregroundColor(.white)
                            
                            factory.makeIconView(item.md5hash)
                                .aspectRatio(contentMode: .fit)
                                .frame(widthAndHeight: config.sizes.icon)
                        }
                        
                        Text(item.title)
                            .font(config.fonts.title)
                            .lineLimit(2)
                            .foregroundColor(config.colors.title)
                    }
                    .padding(.horizontal, config.paddings.horizontal)
                    
                    ForEach(item.limits, id: \.id) {
                        itemView(limitType:item.limitType, limit: $0)
                        if $0 != item.limits.last {
                            
                            HorizontalDivider(color: config.colors.divider)
                                .padding(.vertical, 0)
                        }
                    }
                    .padding(.horizontal, config.paddings.horizontal)
                }
            }
            .frame(width: halfScreenWidth - 1.5 * config.paddings.horizontal, height: config.sizes.height)
        }
        
        private func itemView(
            limitType: String,
            limit: UILanding.List.HorizontalRectangleLimits.Item.Limit
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                Text(limit.title)
                    .font(config.fonts.subTitle)
                    .foregroundColor(config.colors.subtitle)
                
                limitView(limitType: limitType, limit: limit, limitsLoadingStatus: limitsLoadingStatus, color: limit.color)
            }
        }
        
        @ViewBuilder
        private func limitView(
            limitType: String,
            limit: UILanding.List.HorizontalRectangleLimits.Item.Limit,
            limitsLoadingStatus: LimitsLoadingStatus,
            color: Color
        ) -> some View {
            
            switch limitsLoadingStatus {
            case .inflight:
                Rectangle()
                    .fill(config.colors.divider)
                    .frame(height: 24)
                    .frame(maxWidth: .infinity)
                    .shimmering()
                
            case .failure:
                Text("Попробуйте позже")
                    .font(config.fonts.limit)
                    .foregroundColor(config.colors.limitNotSet)

            case let .limits(limits):
                
                if let limitsByType = limits.limitsList.first(where: { $0.type == limitType }), let limit = limitsByType.limits.first(where: { $0.name == limit.id }) {
                    
                    switch limit.value {
                    case .maxLimit...:
                        Text(String.noLimits)
                            .font(config.fonts.limit)
                            .foregroundColor(config.colors.limitNotSet)
                            .frame(height: 24)

                    default:
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(value(limit.value - limit.currentValue) + " " + limit.currency)
                                    .font(config.fonts.limit)
                                    .foregroundColor(config.colors.title)
                                circleLimit(
                                    limit: limit,
                                    mainColor: color,
                                    currentColor: config.colors.arc,
                                    spent: Spent.spentPercent(
                                        limit: limit,
                                        interval: spentConfig.interval,
                                        startAngle: spentConfig.startSpentAngle)
                                )
                                .frame(widthAndHeight: config.sizes.icon)
                            }
                            .frame(height: 24)
                        }
                        
                    }
                } else {
                    Text("Не установлен")
                        .font(config.fonts.limit)
                        .foregroundColor(config.colors.limitNotSet)
                        .frame(height: 24)
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
                    
                    arc(start: spentConfig.startSpentAngle, end: currentAngle, currentColor, spentConfig.spentWidth, spentConfig.size)
                    arc(start: currentAngle + spentConfig.interval, end: spentConfig.startMainAngle, mainColor, spentConfig.mainWidth, spentConfig.mainArcSize)
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
                
        private func value(_ value: Decimal) -> String {
            value > 0 ? value.formattedValue : "0"
        }
    }
}


struct ListHorizontalRectangleLimitsView_Previews: PreviewProvider {
    
    static func state(_ status: LimitsLoadingStatus) -> ListHorizontalRectangleLimitsState {
        .init(
            list: .default,
            limitsLoadingStatus: status
        )
    }
    
    static func preview(_ status: LimitsLoadingStatus) -> ListHorizontalRectangleLimitsView {
        
        ListHorizontalRectangleLimitsView(
            state: state(status),
            event: { _ in },
            factory: .default,
            config: .default)
    }

    static var previews: some View {
        
        Group {
            preview(.inflight(.loadingSVCardLimits))
                .previewDisplayName("inflight")
            
            preview(.failure)
                .previewDisplayName("failure")
            
            preview(.limits(.init(limitsList: [
                .init(type: "Debit", limits: .default),
                .init(type: "Credit", limits: .default)])))
                .previewDisplayName("limits")
            
            preview(.limits(.init(limitsList: [])))
                .previewDisplayName("noLimits")
            
            preview(.limits(.init(limitsList: [.init(type: "", limits: .withoutValue)])))
                .previewDisplayName("withoutValueLimits")
        }
    }
}

extension View {
    
    func frame(
        widthAndHeight: CGFloat
    ) -> some View {
        
        self.frame(
            width: widthAndHeight,
            height: widthAndHeight
        )
    }
}

extension View {
    
    func frame(
        _ config: UILanding.List.HorizontalRectangleLimits.Config
    ) -> some View {
        
        self.frame(
            width: config.sizes.width,
            height: config.sizes.height
        )
    }
}

private extension Decimal {
    
    var formattedValue: String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter.string(for: self) ?? ""
    }
}
