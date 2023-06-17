//
//  Serializer.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 17/6/23.
//

import Foundation

struct Serializer {
    private init() {}

    static func toData<T: Encodable>(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    static func fromData<T: Decodable>(_ value: Data) throws -> T {
        try JSONDecoder().decode(T.self, from: value)
    }
}
