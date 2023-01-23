//
//  Fetcher.swift
//  
//
//  Created by Arnaldo Gnesutta on 3/1/23.
//

import Foundation
import Combine

public enum ResponseError: Error {
    case decoding
    case notFound(message: String? = nil, cause: Error? = nil)
    case badRequest(code: Int = 400, message: String? = nil, cause: Error? = nil)
    case unauthorized(message: String? = nil, cause: Error? = nil)
    case nonTransformable(ref: Int, message: String? = nil, cause: Error? = nil)
    case server(message: String? = nil, cause: Error? = nil)
}

public typealias ResponsePublisher<T> = AnyPublisher<T, ResponseError>

open class Fetcher {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetch<T>(
        with components: URLComponents
    ) -> ResponsePublisher<T> where T: Decodable {
        guard let url = components.url else {
            return Fail(error: ResponseError.badRequest()).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { _ in .badRequest() }
            .flatMap(maxPublishers: .max(1)) { pair in self.decode(pair.data) }
            .eraseToAnyPublisher()
    }
    
    open func decode<T: Decodable>(_ data: Data) -> ResponsePublisher<T> {
        return Just(data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in .decoding }
            .eraseToAnyPublisher()
    }
}

