//
//  Currency.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import Foundation

// MARK: - LatestCurrencies
struct LatestCurrencies: Codable {
    let meta: Meta
    let data: [String: Currency]
}

// MARK: - Currency
struct Currency: Codable {
    let code: String
    let value: Double
}

// MARK: - Meta
struct Meta: Codable {
    let lastUpdatedAt: Date

    enum CodingKeys: String, CodingKey {
        case lastUpdatedAt = "last_updated_at"
    }
}

extension Meta {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lastUpdatedAtString = try values.decode(String.self, forKey: .lastUpdatedAt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: lastUpdatedAtString) else {
            throw DecodingError.typeMismatch(
                Date.self,
                DecodingError.Context(
                    codingPath: values.codingPath,
                    debugDescription: "Could not decode to Date."
                )
            )
        }
        lastUpdatedAt = date
    }
}
