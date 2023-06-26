//
//  MosParkingPickerDataMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.06.2023.
//

protocol MosParkingPickerDataMapper {
    
    func map(
        _ mosParkingPickerData: MosParkingPickerData
    ) -> MosParkingPicker.ViewModel
}
