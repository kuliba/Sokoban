//
//  GetCollateralLandingBottomSheetView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import SwiftUI
import CollateralLoanLandingGetShowcaseUI

public struct GetCollateralLandingBottomSheetView: View {
    
    @SwiftUI.State var selected: Item? = nil

    private var state: State
    private let event: (Event) -> Void
    private let config: Config
    private let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory,
        type: State.BottomSheet.SheetType
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        
        self.state.bottomSheet = .init(sheetType: type)
    }
    
    public var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: config.layouts.spacing) {
                
                ForEach(state.bottomSheetItems, content: itemView)
            }
        }
        .onAppear {
            
            UIScrollView.appearance().isScrollEnabled
                = state.bottomSheetItems.count >= config.layouts.scrollThreshold
            
            selected = state.selectedBottomSheetItem
        }
        .frame(height: height)
    }
    
    private func radioButtonItemView(_ item: Item) -> some View {
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                iconView(for: item)
                    .frame(
                        width: config.radioButton.layouts.size.width,
                        height: config.radioButton.layouts.size.height
                    )
                    .padding(.horizontal, config.radioButton.paddings.horizontal)
                    .padding(.vertical, config.radioButton.paddings.vertical)
                
                Text(item.title)
                    .font(config.font.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .padding(.leading, config.divider.leadingPadding)
                .padding(.trailing, config.divider.trailingPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: cellHeight)
        .onTapGesture {
        
            selected = item
            
            if let termMonth = item.termMonth {
                
                event(.selectMonthPeriod(termMonth))
            }
        }
    }
    
    private func iconItemView(_ item: Item) -> some View {
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                iconView(for: item)
                    .frame(
                        width: config.icon.size.width,
                        height: config.icon.size.height
                    )
                    .padding(.horizontal, config.icon.horizontalPadding)
                    .padding(.vertical, config.icon.verticalPadding)
                
                Text(item.title)
                    .font(config.font.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: cellHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            
            selected = item
            
            event(.selectCollateral(item.id))
        }
    }
    
    @ViewBuilder
    private func iconView(for item: Item) -> some View {
        
        if let icon = item.icon {
            
            factory.makeImageViewWithMD5Hash(icon)
        } else {
            
            makeRadioButton(for: item)
        }
    }
    
    @ViewBuilder
    private func makeRadioButton(for item: Item) -> some View {
        
        if item.title == selected?.title {
            makeSelectedRadioButton(for: item)
        } else {
            makepUnSelectedRadioButton(for: item)
        }
    }
    
    private func makepUnSelectedRadioButton(for item: Item) -> some View {
        
        Circle()
            .stroke(
                config.radioButton.colors.unselected,
                lineWidth: config.radioButton.layouts.lineWidth
            )
            .frame(
                width: config.radioButton.layouts.ringDiameter,
                height: config.radioButton.layouts.ringDiameter
            )
    }
    
    private func makeSelectedRadioButton(for item: Item) -> some View {
        
        Circle()
            .stroke(
                config.radioButton.colors.selected,
                lineWidth: config.radioButton.layouts.lineWidth
            )
            .frame(
                width: config.radioButton.layouts.ringDiameter,
                height: config.radioButton.layouts.ringDiameter
            ).overlay {
                
                Circle()
                    .fill(config.radioButton.colors.selected)
                    .frame(
                        width: config.radioButton.layouts.circleDiameter,
                        height: config.radioButton.layouts.circleDiameter
                    )
            }
    }
    
    @ViewBuilder
    private func itemView(_ item: Item) -> some View {
        
        if isRadioButton {
            
            radioButtonItemView(item)
        } else {
            
            iconItemView(item)
        }
    }
    
    private var isRadioButton: Bool {
        
        state.bottomSheetItems.first?.icon == nil
    }
    
    private var cellHeight: CGFloat {
        
        isRadioButton
            ? config.radioButton.layouts.cellHeigh
            : config.icon.cellHeigh
    }
    
    private var height: CGFloat {
        
        min(
            (cellHeight + config.layouts.cellHeightCompensation) * CGFloat(state.bottomSheetItems.count)
                + config.layouts.sheetBottomOffset,
            UIScreen.main.bounds.height - config.layouts.sheetTopOffset
        )
    }
}

extension GetCollateralLandingBottomSheetView {
    
    public typealias Item = GetCollateralLandingDomain.State.BottomSheet.Item
    public typealias Config = GetCollateralLandingConfig.BottomSheet
    public typealias Factory = GetCollateralLandingFactory
    public typealias Event = GetCollateralLandingDomain.Event
    public typealias State = GetCollateralLandingDomain.State
}

// MARK: - Previews

struct GetCollateralLandingBottomSheetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingBottomSheetView(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                bottomSheet: .init(sheetType: .periods([])),
                formatCurrency: { _ in "" }
            ),
            event: { print($0) },
            config: .preview,
            factory: .preview,
            type: .periods([])
        )
        .previewDisplayName("Product period selector")
        
        GetCollateralLandingBottomSheetView(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                bottomSheet: .init(sheetType: .periods([])),
                formatCurrency: { _ in "" }
            ),
            event: { print($0) },
            config: .preview,
            factory: .preview,
            type: .collaterals([])
        )
        .previewDisplayName("Product collateral selector")
    }
    
    typealias Factory = GetCollateralLandingFactory
    typealias Item = GetCollateralLandingDomain.State.BottomSheet.Item
}
