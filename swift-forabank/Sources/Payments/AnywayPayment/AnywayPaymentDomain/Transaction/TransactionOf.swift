//
//  TransactionOf.swift
//
//
//  Created by Igor Malyarov on 19.05.2024.
//

public typealias TransactionOf<DetailID, Details, DocumentStatus, Context> = Transaction<Context, TransactionStatus<Context, TransactionReport<DocumentStatus, OperationInfo<DetailID, Details>>>>

public typealias TransactionEventOf<DetailID, Details, DocumentStatus, PaymentEvent, PaymentUpdate> = TransactionEvent<TransactionReport<DocumentStatus, OperationInfo<DetailID, Details>>, PaymentEvent, PaymentUpdate>
