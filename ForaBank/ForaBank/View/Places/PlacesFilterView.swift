//
//  PlacesFilterView.swift
//  ForaBank
//
//  Created by Max Gribov on 06.04.2022.
//

import SwiftUI

struct PlacesFilterView: View {
    
    @ObservedObject var viewModel: PlacesFilterViewModel
    
    var body: some View {
        
        VStack {
            
            Capsule()
                .frame(width: 48, height: 4)
                .foregroundColor(.mainColorsGrayMedium)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(viewModel.categoriesSubtitle)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 8) {
                            
                            Color.clear
                                .frame(width: 10, height: 20)
                            
                            ForEach(viewModel.categories) { categoryOption in
                                
                                PlacesFilterView.CategoryOptionView(viewModel: categoryOption, isSelected: viewModel.selectedCategoriesIds.contains(categoryOption.id))
                            }
                        }
                    }
                    .frame(height: 32)
                }
                
                VStack {
                    
                    ForEach(viewModel.services) { serviceGroup in
                        
                        PlacesFilterView.ServiceGroupView(viewModel: serviceGroup, selected: $viewModel.selectedServicesIds)
                        
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 16)
        }
        
    }
}

extension PlacesFilterView {
    
    struct CategoryOptionView: View {
        
        let viewModel: PlacesFilterViewModel.CategoryOptionViewModel
        let isSelected: Bool
        
        var color: Color {
            
            isSelected ? .textWhite : .textSecondary
        }
        
        var backgroundColor: Color {
            
            isSelected ? .buttonBlackMedium : .mainColorsGrayLightest
        }
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                HStack(spacing: 4) {
                    
                    viewModel.icon
                        .renderingMode(.template)
                        .foregroundColor(color)
                    
                    Text(viewModel.name)
                        .font(.textBodyMR14200())
                        .foregroundColor(color)
                }
                .padding(8)
                .background(Capsule().foregroundColor(backgroundColor))
            }
        }
    }
    
    struct ServiceGroupView: View {
        
        let viewModel: PlacesFilterViewModel.ServiceGroupViewModel
        @Binding var selected: Set<PlacesFilterViewModel.ServiceOptionViewModel.ID>
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 16) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsGray)
                
                TagsGridView(data: viewModel.options, spacing: 8, alignment: .leading) { service in
                    
                    PlacesFilterView.ServiceOptionView(viewModel: service, isSelected: selected.contains(service.id))
                }
            }
        }
    }
    
    struct ServiceOptionView: View {
        
        let viewModel: PlacesFilterViewModel.ServiceOptionViewModel
        let isSelected: Bool
        
        var color: Color {
            
            isSelected ? .textSecondary : .textSecondary.opacity(0.1)
        }
        
        var backgroundColor: Color {
            
            isSelected ? .mainColorsGrayLightest : .mainColorsGrayLightest.opacity(0.1)
        }
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.id)
                
            } label: {
                
                HStack(spacing: 4) {
                    
                    Text(viewModel.name)
                        .font(.textBodyMR14200())
                        .foregroundColor(color)
                }
                .padding(8)
                .background(Capsule().foregroundColor(backgroundColor))
            }
        }
    }
}

struct PlacesFilterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlacesFilterView(viewModel: .sample)
    }
}
