//
//  GetCollateralLandingBottomSheetView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

// Do not review, in progress!!

import SwiftUI

struct GetCollateralLandingBottomSheetView: View {
    
    let items: [Item]
    let config: Config
    let makeImageView: Factory.MakeImageView
    let event: (Event) -> Void
    
    @State var selected: Item? = nil
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: config.layouts.spacing) {
                
                ForEach(items, content: itemView)
            }
        }
        .disabled(items.count < config.layouts.scrollThreshold)
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
        .onTapGesture {
            
            event(.selectCollateral(item.id))
        }
    }
    
    @ViewBuilder
    private func iconView(for item: Item) -> some View {
        
        if let icon = item.icon {
            
            makeImageView(icon)
        } else {
            
            makeRadioButton(for: item)
        }
    }
    
    @ViewBuilder
    private func makeRadioButton(for item: Item) -> some View {
        
        if item == selected {
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
        
        items.first?.icon == nil
    }
    
    private var cellHeight: CGFloat {
        
        isRadioButton
            ? config.radioButton.layouts.cellHeigh
            : config.icon.cellHeigh
    }
    
    private var height: CGFloat {
        
        min(
            (cellHeight + config.layouts.cellHeightCompensation) * CGFloat(items.count)
                + config.layouts.sheetBottomOffset,
            UIScreen.main.bounds.height - config.layouts.sheetTopOffset
        )
    }
    
    typealias Item = GetCollateralLandingState.BottomSheet.Item
    typealias Config = GetCollateralLandingConfig.BottomSheet
    typealias Factory = GetCollateralLandingFactory
    typealias Event = GetCollateralLandingEvent
}

// MARK: - Previews

struct GetCollateralLandingBottomSheetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let periodItems: [Item] = [
            .init(
                id: UUID().uuidString,
                termMonth: 1,
                icon: nil,
                title: "1 месяц"
            ),
            .init(
                id: UUID().uuidString,
                termMonth: 2,
                icon: nil,
                title: "2 месяца"
            ),
            .init(
                id: UUID().uuidString,
                termMonth: 12,
                icon: nil,
                title: "1 год"
            )
        ]
        
        let collateralItems: [Item] = [
            .init(
                id: UUID().uuidString,
                termMonth: nil,
                icon: "icon",
                title: "Автомобиль"
            ),
            .init(
                id: UUID().uuidString,
                termMonth: nil,
                icon: "icon",
                title: "Иное движимое имущество"
            )
        ]
        
        GetCollateralLandingBottomSheetView(
            items: periodItems,
            config: .default,
            makeImageView: Factory.preview.makeImageView,
            event: { print($0) },
            selected: periodItems[1]
        )
        .previewDisplayName("Product period selector")
        
        GetCollateralLandingBottomSheetView(
            items: collateralItems,
            config: .default,
            makeImageView: Factory.preview.makeImageView,
            event: { print($0) }
        )
        .previewDisplayName("Product collateral selector")
    }
    
    typealias Factory = GetCollateralLandingFactory
    typealias Item = GetCollateralLandingState.BottomSheet.Item
}
