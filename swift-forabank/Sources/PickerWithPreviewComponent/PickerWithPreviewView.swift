//
//  PickerWithPreviewView.swift
//
//
//  Created by Andryusina Nataly on 05.06.2023.
//
import SwiftUI

public struct PickerWithPreviewView: View {
    
    public let state: ComponentState
    public let send: (ComponentAction) -> Void
    
    public let paymentAction: () -> Void
    public let continueAction: () -> Void
    
    public let checkUncheckImage: CheckUncheckImages
    
    public let viewConfig: PickerWithPreviewContainerView.ViewConfig
    
    public init(
        state: ComponentState,
        send: @escaping (ComponentAction) -> Void,
        paymentAction: @escaping () -> Void,
        continueAction: @escaping () -> Void,
        checkUncheckImage: CheckUncheckImages,
        viewConfig: PickerWithPreviewContainerView.ViewConfig
    ) {
        self.state = state
        self.send = send
        self.paymentAction = paymentAction
        self.continueAction = continueAction
        self.checkUncheckImage = checkUncheckImage
        self.viewConfig = viewConfig
    }
    
    public var body: some View {
        
        VStack {
            
            GeometryReader { geometry in
                
                HStack(spacing: 0) {
                    
                    Button(action:
                            paymentAction
                    ) {
                        ZStack {
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                            Text("Пополнение")
                                .font(viewConfig.fontPickerSegmentTitle)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: (geometry.size.width - viewConfig.trailingPadding - viewConfig.leadingPadding) * 0.33)
                    
                    SegmentedPickerStateView(
                        selectedTag: state.subscriptionType,
                        tags: SubscriptionType.allCases,
                        select: {
                            send(.selectSubscriptionType($0))
                        },
                        tagView: { tag, isSelected in
                            Text(tag.rawValue)
                                .foregroundColor(.black)
                                .font(viewConfig.fontPickerSegmentTitle)
                        }
                    )
                }
            }
            .frame(height: 32)
            
            switch state {
                
            case let .monthly(selectionWithOptions),
                let .yearly(selectionWithOptions):
                
                ImageMapView(mapImage: state.image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ZStack {
                    
                    Rectangle()
                        .fill(viewConfig.backgroundColor)
                        .cornerRadius(16)
                    
                    RadioButtonsView(
                        checkUncheckImage: checkUncheckImage,
                        selection: selectionWithOptions.selection,
                        options: selectionWithOptions.options,
                        viewConfig: viewConfig,
                        select: { send(.selectOption($0)) }
                    )
                    .padding(.leading, 14)
                    .padding(.trailing, 6)
                }
                .frame(maxHeight: .infinity)
            }
            
            Button(action: continueAction) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(viewConfig.countinueButtonBackgroundColor)
                    
                    Text("Продолжить")
                        .foregroundColor(.white)
                }
            }
            .frame(height: 48)
        }
        .padding()
        .navigationTitle(viewConfig.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
