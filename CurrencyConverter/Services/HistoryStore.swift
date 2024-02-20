//
//  HistoryStore.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol HistoryPersistable {
    var items: [Transaction] { get }

    func loadHistory() async throws
    func saveHistory(_ items: [Transaction]) async throws
}

final class HistoryStore: HistoryPersistable {
    var items: [Transaction] = []

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: false
        ).appendingPathComponent("history.data")
    }

    func loadHistory() async throws {
        let task = Task<[Transaction], Error> {
            guard let fileURL = try? Self.fileURL() else {
                throw HistoryStoreError.badURL
            }

            guard let data = try? Data(contentsOf: fileURL) else {
                //throw HistoryStoreError.badData
                return []
            }

            guard let items = try? JSONDecoder().decode([Transaction].self, from: data) else {
                throw HistoryStoreError.failedToDecode
            }

            return items
        }

        let result = await task.result

        do {
            let items = try result.get()
            self.items = items
        } catch HistoryStoreError.badURL {
            throw HistoryStoreError.badURL
        } catch HistoryStoreError.badData {
            throw HistoryStoreError.badData
        } catch HistoryStoreError.failedToDecode {
            throw HistoryStoreError.failedToDecode
        } catch {
            throw HistoryStoreError.unknownError
        }


    }

    func saveHistory(_ items: [Transaction]) async throws {
        let task = Task<Bool, Error> {
            guard let data = try? JSONEncoder().encode(items) else {
                throw HistoryStoreError.failedToEncode
            }

            guard let fileURL = try? Self.fileURL() else {
                throw HistoryStoreError.badURL
            }

            do {
                try data.write(to: fileURL)
                return true
            } catch {
                throw HistoryStoreError.failedToWriteData
            }
        }

        let result = await task.result

        do {
            let _ = try result.get()
        } catch HistoryStoreError.failedToEncode {
            throw HistoryStoreError.failedToEncode
        } catch HistoryStoreError.badURL {
            throw HistoryStoreError.badURL
        } catch HistoryStoreError.failedToWriteData {
            throw HistoryStoreError.failedToWriteData
        } catch {
            throw HistoryStoreError.unknownError
        }
    }
}

enum HistoryStoreError: Error, CustomStringConvertible {
    case badURL
    case badData
    case failedToEncode
    case failedToDecode
    case failedToWriteData
    case unknownError

    var localizedDescription: String {
        self.description
    }

    var description: String {
        switch self {
        case .badURL:
            return "Bad URL for History Store"
        case .badData:
            return "History Store data corrupted"
        case .failedToEncode:
            return "Failed to encode History data"
        case .failedToDecode:
            return "Failed to decode History data"
        case .failedToWriteData:
            return "Failed to write History data"
        case .unknownError:
            return "Unknown error"
        }
    }
}
