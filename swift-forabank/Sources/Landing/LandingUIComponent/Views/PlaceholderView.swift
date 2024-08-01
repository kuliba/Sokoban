import SwiftUI
import UIPrimitives

struct PlaceholderView: View {
    
    private let config: Placeholder.Config
    
    private let width: Placeholder.Config.Width
    private let height: Placeholder.Config.Height
    private let spacing: Placeholder.Config.Spacing
    private let padding: Placeholder.Config.Padding
    private let cornerRadius: Placeholder.Config.CornerRadius
    private let action: (LandingEvent) -> Void

    init(
        config: Placeholder.Config,
        action: @escaping (LandingEvent) -> Void
    ) {
        self.config = config
        self.width = config.width
        self.height = config.height
        self.spacing = config.spacing
        self.padding = config.padding
        self.cornerRadius = config.cornerRadius
        self.action = action
    }
    
    var backButton : some View {
        
        Button(action: {
            action(.card(.goToMain))
        }) { Image(systemName: "chevron.backward") }
    }

    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: spacing.globalVStack) {
                titleView
                    .padding(.bottom, padding.titleBottom)
                bonusesView
                infinityRectangleView(height: height.popularDestinationView)
                infinityRectangleView(
                    height: height.maxTransfersPerMonth,
                    cornerRadius.maxCornerRadius)
                bannersView
                infinityRectangleView(height: height.listOfCountries)
                infinityRectangleView(height: height.advantagesAndSupport)
                infinityRectangleView(height: height.faq)
                infinityRectangleView(height: height.advantagesAndSupport)
                infinityRectangleView(height: height.reference)
            }
            .padding(.horizontal, padding.globalHorizontal)
            .padding(.bottom, padding.globalBottom)
        }
        .navigationBarItems(leading: backButton)
    }
    
    private var titleView: some View {
        VStack(alignment: .leading, spacing: spacing.titleViewSpacing) {
            rectangleView(width: width.title, height: height.titleAndSubtitle)
            rectangleView(width: width.subtitle, height: height.titleAndSubtitle)
        }
    }
    
    private var bonusesView: some View {
        HStack(spacing: spacing.bonuses3inRow) {
            ForEach(0..<3) { _ in
                rectangleView(width: width.bonuses3inRow, height: height.bonuses)
            }
        }
    }
    
    private var bannersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing.bannersView) {
                ForEach(0..<3) { _ in
                    rectangleView(width: width.banner, height: height.bannersView)
                }
            }
        }
    }
    
    @ViewBuilder
    private func rectangle(_ cornerRadius: CGFloat? = nil) -> some View {
        let cornerRadiusValue = cornerRadius ?? self.cornerRadius.roundedRectangle
        
        RoundedRectangle(cornerRadius: cornerRadiusValue)
            .fill(config.gradientColor.fromLeft)
            .shimmering()
            .accessibilityIdentifier("LandingPlaceholderRoundedRectangle")
    }
    
    @ViewBuilder
    private func rectangleView(width: CGFloat, height: CGFloat) -> some View {
        rectangle()
            .frame(width: width, height: height)
    }
    
    @ViewBuilder
    private func infinityRectangleView(
        height: CGFloat,
        _ cornerRadius: CGFloat? = nil
    ) -> some View {
        let cornerRadiusValue = cornerRadius ?? self.cornerRadius.roundedRectangle
        
        rectangle(cornerRadiusValue)
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}

struct Placeholder_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(config: .defaultValue, action: { _ in })
    }
}

