//
//  SavingsAccountDetailsView.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//
import SwiftUI

private extension SavingsAccountDetailsState {
    
    var period: String? {
        
        return reportingPeriod(dateStart: dateStart, dateNext: data?.dateNext)
    }
    
    var dateStart: String? {
        data?.dateStart
    }
    
    var daysLeft: String? {
        data?.daysLeftText
    }
    
    var paydate: String? {
        
        data?.dateNext.map { "Дата выплаты % - \($0.dateToString())" }
    }
    
    var days: String {
       daysLeft ?? ""
    }
    
    func reportingPeriod(
        dateStart: String?,
        dateNext: String?
    ) -> String {
        
        let day: Int = Int(dateStart?.suffix(2) ?? "1") ?? 1
        return "Отчетный период \(day)-\(dateNext?.dateToString() ?? "")"
    }
}

extension Date {
    
    var lastDayOfMonth: Int { Calendar.current.range(of: .day, in: .month, for: self)!.count }
    var day: Int { Calendar.current.component(.day, from:  self) }
    var month: Int { Calendar.current.component(.month, from:  self) }

    var daysToEndMonth: Int { lastDayOfMonth - day }
    
    static var nameOfMonth: String {
        return Date().formatted(Date.FormatStyle().month(.abbreviated))
    }

    func getComponents(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func getComponents(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    var daysInCurrentMonth: Int { Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30 }
}

public struct SavingsAccountDetailsView: View {
    
    private let amountToString: AmountToString
    private let state: SavingsAccountDetailsState
    private let event: (Event) -> Void
    private let config: Config
    
    public init(
        amountToString: @escaping AmountToString,
        state: SavingsAccountDetailsState,
        event: @escaping (Event) -> Void,
        config: Config
    ) {
        self.amountToString = amountToString
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        VStack {
            header(config.texts.header, needShimmering)
                .padding(.bottom, config.padding)
            
            state.period.map {
                
                $0.text(withConfig: config.period)
                    .modifier(HeightWithMaxWidthModifier(height: config.heights.period))
                    .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
                    .padding(.bottom, config.padding / 2)
            }
            
            interest(needShimmering)
            
            lineProgressView(needShimmering)
                .frame(height: config.heights.progress)
            
            if (!needShimmering && state.isExpanded) {
                interest()
            }
        }
        .frame(height: state.isExpanded ? config.heights.big : config.heights.small)
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.colors.background, config.cornerRadius, config.padding))
    }
    
    private func interest() -> some View {
        
        VStack(spacing: config.padding) {
            
            titleWithSubtitle(
                title: .init(text: config.texts.currentInterest, config: config.interestTitle),
                subtitle: .init(text: currentInterest, config: config.interestSubtitle))
            
            titleWithSubtitle(
                title: .init(text: config.texts.paidInterest, config: config.interestTitle),
                subtitle: .init(text: paidInterest, config: config.interestSubtitle))
          
            titleWithSubtitleAndImage(
                    title: .init(text: config.texts.minBalance, config: config.interestTitle),
                    subtitle: .init(text: minBalance, config: config.interestSubtitle))
        }
        .padding(.top, config.padding)
    }
    
    private func titleWithSubtitle(
        title: TextWithConfig,
        subtitle: TextWithConfig
    ) -> some View {
        
        VStack(spacing: config.padding / 2 ) {
            
            title.text.text(withConfig: title.config)
                .frame(maxWidth: .infinity, alignment: .leading)
            subtitle.text.text(withConfig: subtitle.config)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 48)
    }
    
    private func titleWithSubtitleAndImage(
        title: TextWithConfig,
        subtitle: TextWithConfig
    ) -> some View {
        
        VStack(spacing: config.padding / 2 ) {
            
            title.text.text(withConfig: title.config)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                subtitle.text.text(withConfig: subtitle.config)
                    .frame(alignment: .leading)
                config.info
                    .foregroundColor(config.colors.chevron)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func interest(
        _ needShimmering: Bool
    ) -> some View {
        
        HStack {
            
            state.paydate.map {
                
                $0.string(needShimmering)
                    .text(withConfig: config.interestDate)
                    .modifier(HeightWithMaxWidthModifier(height: config.heights.interest))
                    .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
            }
            
            if !needShimmering, !state.days.isEmpty {
                config.info
                    .foregroundColor(config.colors.chevron)
                state.days
                    .text(withConfig: config.days)
            }
        }
        .padding(.bottom, config.padding / 2)
    }
    
    private func header(
        _ header: TextWithConfig,
        _ needShimmering: Bool
    ) -> some View {
        
        HStack {
            header.text
                .string(needShimmering)
                .text(withConfig: header.config)
                .modifier(HeightWithMaxWidthModifier(height: config.heights.header))
                .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
            
            if !needShimmering {
                config.chevronDown
                    .foregroundColor(config.colors.chevron)
                    .rotationEffect(state.isExpanded ? .degrees(180) : .degrees(0))
            }
        }
        .onTapGesture {
            event(.expanded)
        }
    }
    
    private func lineProgressView(
        _ needShimmering: Bool
    ) -> some View {
        
        GeometryReader { geometry in
            
            ZStack() {
                Capsule()
                    .stroke(config.colors.progress, lineWidth: 1)
                    .frame(height: config.heights.progress)
                    .background(needShimmering ? config.colors.shimmering : .clear)
                    .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
                
                if !needShimmering {
                    ruler(width: geometry.size.width, days: Date().daysInCurrentMonth)
                    progress(width: geometry.size.width, value: state.data?.progress)
                }
            }
            .frame(height: config.heights.progress)
        }
    }
    
    private func ruler(
        width: CGFloat,
        days: Int
    ) -> some View {
        
        HStack(spacing: (width - config.padding * 2) / CGFloat(days)) {
            ForEach(0..<days, id: \.self) { _ in
                Capsule()
                    .frame(width: 1, height: 2)
                    .foregroundColor(config.colors.progress)
            }
        }
    }
    
    private func progress(
        width: CGFloat,
        value: CGFloat?
    ) -> some View {
        
        Capsule()
            .fill(LinearGradient(
                gradient: .init(colors: config.progressColors),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .padding(2)
            .clipShape(ClipArea(width: width * min(max(value ?? 0, 0), 1)))
    }
    
    struct ClipArea: Shape {
        
        let width: CGFloat
        
        func path(in rect: CGRect) -> Path {
            return Rectangle().path(in: .init(
                x: rect.minX,
                y: rect.minY,
                width: width,
                height: rect.height)
            )
        }
    }
}

public extension SavingsAccountDetailsView {
    
    typealias AmountToString = (Decimal, String) -> String
    typealias Event = SavingsAccountDetailsEvent
    typealias Config = SavingsAccountDetailsConfig
}

private extension SavingsAccountDetailsView {
    
    var needShimmering: Bool {
        state.data == nil
    }
}

private extension SavingsAccountDetailsView {
   
    var currentInterest: String {
        if let currentInterest = state.currentInterest {
            return amountToString(currentInterest, state.currencyCode)
        }
        return ""
    }
    
    var minBalance: String {
        if let minBalance = state.minBalance, minBalance > 0 {
            amountToString(minBalance, state.currencyCode) + config.texts.per
        } else {
            ""
        }
    }

    var paidInterest: String {
        if let paidInterest = state.paidInterest {
            amountToString(paidInterest, state.currencyCode)
        } else {
            ""
        }
    }
}
private extension SavingsAccountDetailsState {
    
    var currentInterest: Decimal? { data?.interestAmount }
    
    var minBalance: Decimal? { data?.minRest}

    var paidInterest: Decimal? { data?.interestPaid }

    var currencyCode: String { data?.currencyCode ?? "" }
}

private struct HeightWithMaxWidthModifier: ViewModifier {
    
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SavingsAccountDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            SavingsAccountDetailsWrapperView.init(
                viewModel: .init(
                    initialState: .init(status: .inflight),
                    reduce: { state, _ in return (state, .none) },
                    handleEffect: {_,_ in }),
                config: .preview
            )
            Spacer()
        }
        .padding()
        .previewDisplayName("Placeholder")
        
        VStack {
            SavingsAccountDetailsWrapperView.init(
                viewModel: .init(
                    initialState: .init(status: .result(.preview)),
                    reduce: { state, event in
                        
                        var state = state
                        switch event {
                        case .expanded:
                            state.isExpanded.toggle()
                        }
                        
                        return (state, .none)
                    },
                    handleEffect: {_,_ in }),
                config: .preview
            )
            Spacer()
        }
        .padding()
        .previewDisplayName("Value")
    }
}

// TODO: move to main target

import RxViewModel
import SharedConfigs

struct SavingsAccountDetailsWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    
    init(
        viewModel: ViewModel,
        config: Config
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        RxWrapperView(
            model: viewModel,
            makeContentView: {
                SavingsAccountDetailsView(
                    amountToString: { "\($0)" + " " + $1 },
                    state: $0,
                    event: $1,
                    config: config
                )
            }
        )
    }
}

extension SavingsAccountDetailsWrapperView {
    
    typealias ViewModel = SavingsAccountDetailsViewModel
    typealias Config = SavingsAccountDetailsConfig
}

typealias SavingsAccountDetailsViewModel = RxViewModel<SavingsAccountDetailsState, SavingsAccountDetailsEvent, SavingsAccountDetailsEffect>

extension String {
    
    // 2024-12-31
    func dateToString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: self)
        
        if let components = date?.getComponents(.day, .month), let day = components.day, let month = components.month {
            switch (day, month) {
                
            case (31, 1): return "\(day) января"
            case (28, 2): return "\(day) февраля"
            case (29, 2): return "\(day) февраля"
            case (31, 3): return "\(day) марта"
            case (30, 4): return "\(day) апреля"
            case (31, 5): return "\(day) мая"
            case (30, 6): return "\(day) июня"
            case (31, 7): return "\(day) июля"
            case (31, 8): return "\(day) августа"
            case (30, 9): return "\(day) сентября"
            case (31, 10): return "\(day) октября"
            case (30, 11): return "\(day) ноября"
            case (31, 12): return "\(day) декабря"
                
            default: return "\(day).\(month)"
            }
        }
        return self
    }
}
