//
//  File.swift
//  
//
//  Created by Pinar Olguc on 24.01.2024.
//

import Foundation

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession : URLSessionProtocol { }
