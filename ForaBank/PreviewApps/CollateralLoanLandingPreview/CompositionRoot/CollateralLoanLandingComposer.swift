//
//  CollateralLoanLandingComposer.swift
//  CollateralLoanLandingPreview
//
//  Created by Valentin Ozerov on 06.11.2024.
//

import Foundation
import PayHub
import PayHubUI
import RemoteServices
import CollateralLoanLandingGetShowcaseBackend
import CollateralLoanLandingGetShowcaseUI

final class CollateralLoanLandingComposer {
        
    private let json: String
    
    init(json: String = .stub) {
        self.json = json
    }
    
    func compose() -> CollaterlLoanPicker {
        
        let composer = LoadablePickerModelComposer(
            load: load,
            reload: load,
            scheduler: .main)
        
        return composer.compose(
            prefix: [],
            suffix: [.placeholder(.init())],
            placeholderCount: 1)
    }
    
    private func load(
        completion: @escaping ([CollateralLoadProduct]?) -> Void
    ) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) { [weak self] in
            
            guard let self else { return }
            
            let response = ResponseMapper.mapCreateGetShowcaseResponse(
                .init(self.json.utf8),
                .init(
                    url: URL(string: "http://www.url.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
            
            completion(try? response.get().products.map { $0.map() })
        }
    }
}

private extension String {
    
    static let stub = """
{
   "statusCode": 200,
   "errorMessage": null,
   "data": {
      "serial":"d0f7b46028dc52536477c4639198658a",
      "products":[
         {
            "theme":"WHITE",
            "name":"Кредит под залог транспорта",
            "keyMarketingParams":{
               "rate":"от 17,5%",
               "amount":"до 15 млн ₽",
               "term":"До 84 месяцев"
            },
            "features":{
               "list":[
                  {
                     "bullet":true,
                     "text":"0 ₽. Условия обслуживания"
                  },
                  {
                     "bullet":false,
                     "text":"Кешбэк до 10 000 ₽ в месяц"
                  },
                  {
                     "bullet":true,
                     "text":"5% выгода при покупке топлива"
                  }
               ]
            },
            "image":"dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_car_collateral_loan.png",
            "terms":"https://www.innovation.ru/",
            "landingId":"COLLATERAL_LOAN_CALC_CAR"
         },
         {
            "theme":"GRAY",
            "name":"Кредит под залог недвижимости",
            "keyMarketingParams":{
               "rate":"от 16,5 %",
               "amount":"до 15 млн. ₽",
               "term":"до 10 лет"
            },
            "features":{
               "header":"Под залог:",
               "list":[
                  {
                     "bullet":false,
                     "text":"Квартиры"
                  },
                  {
                     "bullet":false,
                     "text":"Жилого дома с земельным участком"
                  },
                  {
                     "bullet":true,
                     "text":"Нежилого или складского помещения"
                  }
               ],
            },
            "image":"dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_real_estate_collateral_loan.png",
            "terms":"https://www.innovation.ru/",
            "landingId":"COLLATERAL_LOAN_CALC_REAL_ESTATE"
         }
      ]
   }
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
}
