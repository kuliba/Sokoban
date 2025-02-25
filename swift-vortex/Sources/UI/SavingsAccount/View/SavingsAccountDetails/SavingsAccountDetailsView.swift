//
//  SavingsAccountDetailsView.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//
import SwiftUI

private extension SavingsAccountDetailsState {
    
    var period: String? {
        
        data?.dateNext.map { "Отчетный период с 01 по \($0.suffix(2))" }
    }
    
    var paydate: String? {
        
        data?.dateNext.map { "Дата выплаты % - \($0.suffix(2))" }
    }
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
                (subtitle.text + config.texts.per).text(withConfig: subtitle.config)
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
            
            if (!needShimmering) {
                config.info
                    .foregroundColor(config.colors.chevron)
                config.texts.days
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
                    ruler(width: geometry.size.width)
                    progress(width: geometry.size.width, value: state.data?.progress)
                }
            }
            .frame(height: config.heights.progress)
        }
    }
    
    private func ruler(
        width: CGFloat
    ) -> some View {
        
        HStack(spacing: (width - config.padding * 2) / 40) {
            ForEach(0..<40) { _ in
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
        amountToString(state.currentInterest, state.currencyCode)
    }
    
    var minBalance: String {
        amountToString(state.minBalance, state.currencyCode)
    }

    var paidInterest: String {
        amountToString(state.paidInterest, state.currencyCode)
    }
}
private extension SavingsAccountDetailsState {
    
    var currentInterest: Decimal { data?.currentInterest ?? 0 }
    
    var minBalance: Decimal { data?.minBalance ?? 0 }

    var paidInterest: Decimal { data?.paidInterest ?? 0 }

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
