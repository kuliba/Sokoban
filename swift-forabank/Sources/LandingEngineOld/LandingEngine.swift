//
//  File.swift
//  
//
//  Created by Dmitry Martynov on 25.07.2023.
//

import SwiftUI
import LandingComponentsOld

public class LandingEngine {
    
    public init() {}
    
    public func getLandingViewModels(landingModels: LandingDataResponse,
                                     imagesDelegate: ImageProviderDelegate) -> [LandingComponentsViewModel] {
        
        var viewModels = [LandingComponentsViewModel]()
        
        for item in landingModels.main.components {
            
            switch item {
            case .listHorizontalRoundImage(let model):
                viewModels.append(.listHorizontalRoundImage(model.reduce(imagesDelegate: imagesDelegate)))
                
            case .multiLineHeader(let model):
                viewModels.append(.multiLineHeader(model.reduce()))
            
            case .iconWithTwoTextLines(let model):
               continue
                
            case .verticalSpacing(let model):
                continue
            
            case .textWithIconHorizontal(let model):
                viewModels.append(.textWithIconHorizontal(model.reduce(imagesDelegate: imagesDelegate)))
            
            case .listHorizontalRectangleImage(let model):
                viewModels.append(.listHorizontalRectangleImage(model.reduce(imagesDelegate: imagesDelegate)))
            
            case .listVerticalRoundImage(let model):
                viewModels.append(.listVerticalRoundImage(model.reduce(imagesDelegate: imagesDelegate)))
            
            case .multiButtons(let model):
                viewModels.append(.multiButtons(model.reduce()))
            
            case .listDropDownTexts(let model):
                viewModels.append(.listDropDownTexts(model.reduce()))
            
            case .multiText(let model):
                viewModels.append(.multiText(model.reduce()))
            
            case .pageTitle(let model):
                viewModels.append(.pageTitle(model.reduce()))
            
            case .image(let model):
                viewModels.append(.image(model.reduce(imagesDelegate: imagesDelegate)))
            }
            
        }
        
        return viewModels
    }

}

public enum LandingComponentsViewModel: Hashable {

    case listHorizontalRoundImage(ListHorizontalRoundImageViewModel)
    case multiLineHeader(MultiLineHeaderViewModel)
    case textWithIconHorizontal(TextWithIconHorizontalViewModel)
    case listHorizontalRectangleImage(ListHorizontalRectangleImageViewModel)
    case listVerticalRoundImage(ListVerticalRoundImageViewModel)
    case multiButtons(MultiButtonsViewModel)
    case listDropDownTexts(ListDropDownTextsViewModel)
    case multiText(MultiTextViewModel)
    case pageTitle(PageTitleViewModel)
    case image(ImageViewModel)
}

public struct LandingView: View {
    
    let componentsViewModelList: [LandingComponentsViewModel]
    
    public init(componentsViewModelList: [LandingComponentsViewModel]) {
        self.componentsViewModelList = componentsViewModelList
    }
    
    public var body: some View {
        
        ScrollView {
            
            ForEach(componentsViewModelList, id: \.self) { componentViewModel in
                
                //TODO: ComponentView()
                
                switch componentViewModel {
                case .listHorizontalRoundImage(let viewModel):
                    ListHorizontalRoundImageView(viewModel: viewModel)
                
                case .multiLineHeader(let viewModel):
                    MultiLineHeaderView(viewModel: viewModel)
                    
                case .textWithIconHorizontal(let viewModel):
                    TextWithIconHorizontalView(viewModel: viewModel)
                    
                case .listHorizontalRectangleImage(let viewModel):
                    ListHorizontalRectangleImageView(viewModel: viewModel)
                    
                case .listVerticalRoundImage(let viewModel):
                    ListVerticalRoundImageView(viewModel: viewModel)
                
                case .multiButtons(let viewModel):
                    MultiButtonsView(viewModel: viewModel)
                
                case .listDropDownTexts(let viewModel):
                    ListDropDownTextsView(viewModel: viewModel)
                
                case .multiText(let viewModel):
                    MultiTextView(viewModel: viewModel)
                
                case .pageTitle(let viewModel):
                    PageTitleView(viewModel: viewModel)
                
                case .image(let viewModel):
                    ImageView(viewModel: viewModel)
                }
            }
        }
        
    }
    
}


