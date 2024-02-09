//
//  SwiftUIView.swift
//  
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI
import SearchBarComponent

struct ComposedOperatorsView: View {
    
    let operators: [OperatorViewModel]
    let selectEvent: (OperatorViewModel.ID) -> Void
    let noCompaniesButtons: [ButtonSimpleView.ViewModel]
    
    let configuration: Configuration
    
    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(operators, content: operatorView)
                
                NoCompanyInListView(
                    noCompanyListViewModel: .init(
                        title: NoCompanyInListView.title,
                        description: NoCompanyInListView.description,
                        subtitle: NoCompanyInListView.subtitle,
                        buttons: noCompaniesButtons
                    ),
                    config: configuration.noCompanyListConfiguration
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

extension ComposedOperatorsView {
    
    private func operatorView(
        _ operatorViewModel: ComposedOperatorsView.OperatorViewModel
    ) -> some View {
        
        Button {
            selectEvent(operatorViewModel.id)
        } label: {
            
            HStack {
             
                operatorViewModel.image
                
                VStack {

                    Text(operatorViewModel.title)
                    Text(operatorViewModel.subtitle)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

extension ComposedOperatorsView {
    
    struct Configuration {
        
        let noCompanyListConfiguration: NoCompanyInListView.NoCompanyInListViewConfig
        
    }
    struct OperatorViewModel: Identifiable {
        
        var id: String { self.title }
        let title: String
        let subtitle: String
        let image: Image
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        ComposedOperatorsView(
            operators: [],
            selectEvent: { _ in },
            noCompaniesButtons: [],
            configuration: .init(noCompanyListConfiguration: .init(
                titleFont: .body,
                titleColor: .red,
                descriptionFont: .body,
                descriptionColor: .black,
                subtitleFont: .body,
                subtitleColor: .blue
            ))
        )
    }
}
