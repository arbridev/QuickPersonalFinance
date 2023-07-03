//
//  ExternalCurrencyService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import Foundation

// MARK: - External currency service protocol

protocol ExternalCurrencyService: Actor {
    func fetchLatestCurrencies() async throws -> LatestCurrencies
}

// MARK: - External currency

actor ExternalCurrency: ExternalCurrencyService {

    /// Fetches the currency data.
    /// - Returns: A LatestCurrencies structure with the currency data.
    func fetchLatestCurrencies() async throws -> LatestCurrencies {
        let stringURL = Constant.currencyAPIURL + URL.Endpoint.latest
        guard let url = URL(string: stringURL) else {
            throw ExternalCurrencyError.wrongURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
            throw ExternalCurrencyError.unsuccessful
        }

        do {
            let serialized: LatestCurrencies = try Serializer.fromData(data)
            return serialized
        } catch {
            print(error)
            throw ExternalCurrencyError.wrongData
        }
    }
}

// MARK: - Endpoints for external currency

fileprivate extension URL {
    struct Endpoint {
        static let latest = ""
        private init() {}
    }
}

// MARK: - External currency error

fileprivate extension ExternalCurrency {
    enum ExternalCurrencyError: LocalizedError {
        case wrongURL
        case unsuccessful
        case wrongData

        var errorDescription: String? {
            switch self {
                case .wrongURL:
                    return "external.error.wrong.url".localized
                case .wrongData:
                    return "external.error.wrong.data".localized
                default:
                    return "external.error.unsuccessful".localized
            }
        }
    }
}
