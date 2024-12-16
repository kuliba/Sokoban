//
//  PrepaymentPickerState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public typealias PrepaymentPickerState<LastPayment, Operator> = Result<PrepaymentPickerSuccess<LastPayment, Operator>, Error>
