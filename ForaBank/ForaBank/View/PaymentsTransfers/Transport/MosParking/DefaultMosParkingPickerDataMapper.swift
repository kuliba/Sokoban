//
//  DefaultMosParkingPickerDataMapper.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.06.2023.
//

struct DefaultMosParkingPickerDataMapper {
    
    typealias Select = (MosParkingPicker.ViewModel.ID) -> Void
    
    private let select: Select
    
    init(select: @escaping Select) {
        self.select = select
    }
}

extension DefaultMosParkingPickerDataMapper: MosParkingPickerDataMapper {
    
    func map(
        _ data: MosParkingPickerData
    ) -> MosParkingPicker.ViewModel {
        
        .init(
            initialState: data.state,
            options: data.options,
            refillID: data.refillID,
            select: self.select
        )
    }
}
