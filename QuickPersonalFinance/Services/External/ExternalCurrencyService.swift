//
//  ExternalCurrencyService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/6/23.
//

import Foundation

protocol ExternalCurrencyService: Actor {
    func fetchLatestCurrencies() async throws -> LatestCurrencies
}

actor ExternalCurrency: ExternalCurrencyService {

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

fileprivate extension URL {
    struct Endpoint {
        static let latest = ""
        private init() {}
    }
}

fileprivate extension ExternalCurrency {
    enum ExternalCurrencyError: Error {
        case wrongURL
        case unsuccessful
        case wrongData

        var localizedDescription: String {
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
