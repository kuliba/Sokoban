//
//  UtilityPrepaymentMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPrepaymentMicroServices<Operator>
where Operator: Identifiable{
    
    let paginate: Paginate
    let search: Search
}

extension UtilityPrepaymentMicroServices {
    
    typealias Paginate = PrepaymentPickerEffectHandler<Operator>.Paginate
    typealias Search = PrepaymentPickerEffectHandler<Operator>.Search
}
