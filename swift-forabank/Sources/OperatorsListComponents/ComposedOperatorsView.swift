//
//  SwiftUIView.swift
//  
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI

public struct ComposedOperatorsView<SearchView: View>: View {
    
    let operators: [OperatorViewModel]
    let latestPayments: [LatestPayment]
    let selectEvent: (OperatorViewModel.ID) -> Void
    let noCompaniesButtons: [ButtonSimpleViewModel]
    let searchView: () -> SearchView
    
    let configuration: Configuration
    
    public init(
        operators: [OperatorViewModel],
        latestPayments: [LatestPayment],
        selectEvent: @escaping (OperatorViewModel.ID) -> Void,
        noCompaniesButtons: [ButtonSimpleViewModel],
        searchView: @escaping () -> SearchView,
        configuration: Configuration
    ) {
        self.operators = operators
        self.latestPayments = latestPayments
        self.selectEvent = selectEvent
        self.noCompaniesButtons = noCompaniesButtons
        self.searchView = searchView
        self.configuration = configuration
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            searchView()
            
            VStack(spacing: 32) {
                
                ScrollView(.horizontal) {
                    
                    ForEach(latestPayments, content:  lastPaymentView)
                    
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    
                    ForEach(operators, content: operatorView)
                }
                
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
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

extension ComposedOperatorsView {
    
    private func lastPaymentView(
        latestPayment: ComposedOperatorsView.LatestPayment
    ) -> some View {
        
        Button {
            selectEvent("")
        } label: {
            
            VStack {
             
                latestPayment.image
                    .resizable()
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                VStack(spacing: 8) {

                    Text(latestPayment.title)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        
                        Text(latestPayment.amount)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                }
            }
            .frame(width: 80, height: 80, alignment: .center)
        }
        .contentShape(Rectangle())
    }
    
    private func operatorView(
        _ operatorViewModel: ComposedOperatorsView.OperatorViewModel
    ) -> some View {
        
        Button {
            selectEvent(operatorViewModel.id)
        } label: {
            
            HStack {
             
                operatorViewModel.image
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                VStack(spacing: 8) {

                    Text(operatorViewModel.title)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .lineLimit(1)
                    
                    if let subtitle = operatorViewModel.subtitle {
                        
                        Text(subtitle)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
            .frame(height: 56)
        }
        .contentShape(Rectangle())
    }
}

extension ComposedOperatorsView {
    
    public struct Configuration {
        
        let noCompanyListConfiguration: NoCompanyInListViewConfig
        
        public init(
            noCompanyListConfiguration: NoCompanyInListViewConfig
        ) {
            self.noCompanyListConfiguration = noCompanyListConfiguration
        }
    }
    
    public struct OperatorViewModel: Identifiable {
        
        public var id: String { self.title }
        let title: String
        let subtitle: String?
        let image: Image
        
        public init(
            title: String,
            subtitle: String?,
            image: Image
        ) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
        }
    }
    
    public struct LatestPayment: Identifiable {
        
        public var id: String { title }
        let image: Image
        let title: String
        let amount: String
        
        public init(
            image: Image,
            title: String,
            amount: String
        ) {
            self.image = image
            self.title = title
            self.amount = amount
        }
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        ComposedOperatorsView<EmptyView>(
            operators: [],
            latestPayments: [],
            selectEvent: { _ in },
            noCompaniesButtons: [],
            searchView: { EmptyView() },
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
