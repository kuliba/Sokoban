//
//  CarouselViewModel.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import RxViewModel

public typealias CarouselViewModel<Product: CarouselProduct & Equatable & Identifiable> = RxViewModel<CarouselState<Product>, CarouselEvent<Product>, CarouselEffect>
