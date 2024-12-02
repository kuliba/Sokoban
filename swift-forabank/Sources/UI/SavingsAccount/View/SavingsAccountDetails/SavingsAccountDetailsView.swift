//
//  SavingsAccountDetailsView.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//
import SwiftUI

struct SavingsAccountDetailsView: View {
    
    let state: SavingsAccountDetailsState
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        VStack {
            header(config.header, needShimmering)
                .padding(.bottom, config.padding)
            config.texts.period
                .string(needShimmering)
                .text(withConfig: config.period)
                .modifier(HeightWithMaxWidthModifier(height: config.heights.period))
                .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
                .padding(.bottom, config.padding / 2)
            interest(needShimmering)
            lineProgressView(needShimmering)
        }
        .frame(height: state.isExpanded ? config.heights.big : config.heights.small)
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.colors.background, config.cornerRadius, config.padding))
    }
    
    private func interest(
        _ needShimmering: Bool
    ) -> some View {
        
        HStack {
            config.texts.interestDate
                .string(needShimmering)
                .text(withConfig: config.interestDate)
                .modifier(HeightWithMaxWidthModifier(height: config.heights.interest))
                .modifier(ShimmeringModifier(needShimmering, config.colors.shimmering))
            
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

private extension String {
    
    func string(
        _ needShimmering: Bool
    ) -> String {
        needShimmering ? "" : self
    }
}

extension SavingsAccountDetailsView {
    
    typealias Event = SavingsAccountDetailsEvent
    typealias Config = SavingsAccountDetailsConfig
}

private extension SavingsAccountDetailsView {
    
    var needShimmering: Bool {
        state.data == nil
    }
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
