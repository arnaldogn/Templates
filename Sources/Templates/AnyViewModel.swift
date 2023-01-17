//
//  AnyViewModel.swift
//  Weather
//
//  Created by Arnaldo Gnesutta on 2/1/23.
//

import Foundation
import Combine

public protocol ViewModelProtocol: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype Input
    associatedtype Data

    var data: Data { get }
    func trigger(_ input: Input)
}

@dynamicMemberLookup
public final class AnyViewModel<Input, Data>: ViewModelProtocol {
    private let wrappedObjectWillChange: () -> AnyPublisher<Void, Never>
    private let wrappedData: () -> Data
    private let wrappedTrigger: (Input) -> Void

    public init<VM: ViewModelProtocol>(_ viewModel: VM) where VM.Input == Input, VM.Data == Data {
        wrappedObjectWillChange = { viewModel.objectWillChange.eraseToAnyPublisher() }
        wrappedData = { viewModel.data }
        wrappedTrigger = viewModel.trigger
    }
}

public extension AnyViewModel {

    var objectWillChange: AnyPublisher<Void, Never> { wrappedObjectWillChange() }

    var data: Data { wrappedData() }

    subscript<Value>(dynamicMember keypath: KeyPath<Data, Value>) -> Value {
        data[keyPath: keypath]
    }

    /// Use this method to try data via input
    ///
    /// - Parameters:
    ///     - input: Input (enum)

    func trigger(_ input: Input) {
        wrappedTrigger(input)
    }

    /// Use this method to try multiple actions via input
    ///
    /// - Parameters:
    ///     - inputs: Array of inputs (enum)

    func trigger(_ inputs: Input...) {
        inputs.forEach { wrappedTrigger($0) }
    }

}
