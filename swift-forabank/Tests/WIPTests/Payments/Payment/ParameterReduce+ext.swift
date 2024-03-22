//
//  ParameterReduce+ext.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

struct ParameterReduce {
    
    let inputReduce: InputReduce
    let selectReduce: SelectReduce
}

extension ParameterReduce {
    
    typealias InputReduce = (InputParameter, InputParameterEvent) -> (InputParameter, InputParameterEffect?)
    typealias SelectReduce = (SelectParameter, SelectParameterEvent) -> (SelectParameter, SelectParameterEffect?)
}

extension ParameterReduce {
    
    static var `default`: Self {
        
        let inputParameterReducer = InputParameterReducer()
        let selectParameterReducer = SelectParameterReducer()
        
        return .init(
            inputReduce: inputParameterReducer.reduce(_:_:),
            selectReduce: selectParameterReducer.reduce(_:_:)
        )
    }
}
