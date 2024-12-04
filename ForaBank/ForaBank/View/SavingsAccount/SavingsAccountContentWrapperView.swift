//
//  SavingsAccountContentWrapperView.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import SavingsAccount
import RxViewModel

typealias SavingsAccountContentWrapperView = RxWrapperView<SavingsAccountContentView<SpinnerRefreshView, SavingsAccountWrapperView, SavingsAccountDomain.Landing, SavingsAccountDomain.InformerPayload>, SavingsAccountContentState<SavingsAccountDomain.Landing, SavingsAccountDomain.InformerPayload>, SavingsAccountContentEvent<SavingsAccountDomain.Landing, SavingsAccountDomain.InformerPayload>, SavingsAccountContentEffect>
