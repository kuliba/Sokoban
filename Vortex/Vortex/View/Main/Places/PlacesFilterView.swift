//
//  PlacesFilterView.swift
//  Vortex
//
//  Created by Max Gribov on 06.04.2022.
//

import SwiftUI

struct PlacesFilterView: View {
    
    @ObservedObject var viewModel: PlacesFilterViewModel
    
    var body: some View {
        
        VStack {
            
            dragIndicator()
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 20) {
                
                title()
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    subtitle()
                        .padding(.horizontal, 20)
                    
                    categoriesView()
                        .frame(height: 32)
                }
                
                servicesView()
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 16)
        }
    }
    
    private func dragIndicator() -> some View {
        
        Capsule()
            .frame(width: 48, height: 4)
            .foregroundColor(.mainColorsGrayMedium)
    }
    
    private func title() -> some View {
        
        Text(viewModel.title)
            .font(.textH3Sb18240())
            .foregroundColor(.mainColorsBlack)
    }
    
    private func subtitle() -> some View {
        
        Text(viewModel.categoriesSubtitle)
            .font(.textBodyMR14200())
            .foregroundColor(.mainColorsGray)
    }
    
    private func categoriesView() -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                Color.clear
                    .frame(width: 10, height: 20)
                
                ForEach(viewModel.categories, content: categoryOptionView)
            }
        }
    }
    
    private func categoryOptionView(
        categoryOption: PlacesFilterViewModel.CategoryOptionViewModel
    ) -> some View {
        
        CategoryOptionView(
            viewModel: categoryOption,
            isSelected: viewModel.selectedCategoriesIds.contains(categoryOption.id)
        )
    }
    
    private func servicesView() -> some View {
        
        VStack(spacing: 24) {
            
            ForEach(viewModel.services, content: serviceGroupView)
        }
    }
    
    private func serviceGroupView(
        serviceGroup: PlacesFilterViewModel.ServiceGroupViewModel
    ) -> some View {
        
        ServiceGroupView(
            viewModel: serviceGroup,
            selected: $viewModel.selectedServicesIds,
            available: $viewModel.availableServicesIds
        )
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
        @Binding var available: Set<PlacesFilterViewModel.ServiceOptionViewModel.ID>
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 16) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsGray)
                
                TagsGridView(
                    data: viewModel.options,
                    spacing: 8,
                    alignment: .leading,
                    content: serviceView
                )
            }
        }
        
        private func serviceView(
            service: PlacesFilterViewModel.ServiceOptionViewModel
        ) -> some View {
            
            ServiceOptionView(
                viewModel: service,
                isSelected: selected.contains(service.id),
                isAvailable: available.contains(service.id)
            )
        }
    }
    
    struct ServiceOptionView: View {
        
        let viewModel: PlacesFilterViewModel.ServiceOptionViewModel
        let isSelected: Bool
        let isAvailable: Bool
        
        var color: Color {
            
            isAvailable
            ? isSelected ? .textWhite : .textSecondary
            : .textSecondary.opacity(0.1)
        }
        
        var backgroundColor: Color {
            
            isAvailable
            ? isSelected ? .buttonBlackMedium : .mainColorsGrayLightest
            :.mainColorsGrayLightest.opacity(0.1)
        }
        
        var body: some View {
            
            if isAvailable {
                
                Button(action: { viewModel.action(viewModel.id) }, label: label)
                
            } else {
                
                label()
            }
        }
        
        func label() -> some View {
            
            Text(viewModel.name)
                .font(.textBodyMR14200())
                .foregroundColor(color)
                .padding(8)
                .background(Capsule().foregroundColor(backgroundColor))
        }
    }
}

struct PlacesFilterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlacesFilterView(viewModel: .sample)
    }
}
