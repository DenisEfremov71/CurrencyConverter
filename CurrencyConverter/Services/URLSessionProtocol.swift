//
//  URLSessionProtocol.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol URLSessionProtocol: AnyObject {
    func makeDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol
}

protocol URLSessionTaskProtocol: AnyObject {
    func resume()
}

extension URLSessionTask: URLSessionTaskProtocol {}

extension URLSession: URLSessionProtocol {
    func makeDataTask(
        with url: URL,
        completionHandler:
        @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}
