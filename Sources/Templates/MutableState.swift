//
//  MutableState.swift
//  Weather
//
//  Created by Arnaldo Gnesutta on 2/1/23.
//

import Foundation
import Combine

open class MutableState<ViewState> {
    lazy var state = { CurrentValueSubject<ViewState?, Never>(nil) }()
    
    public init() {}

}

public protocol MutableStateData {
    associatedtype ViewState
    var mutable: MutableState<ViewState> { get }
}

public extension MutableStateData {
    var state: CurrentValueSubject<ViewState?, Never> {
        get { mutable.state }
        set { mutable.state = newValue }
    }
}
