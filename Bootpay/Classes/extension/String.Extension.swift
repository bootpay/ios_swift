//
//  String.Extension.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

import Foundation
import CommonCrypto

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}


extension String {
    subscript (i: Int) -> Character {

        return self[index(startIndex, offsetBy: i)]
    }

    public func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public func aesEncrypt(key: String, iv: String) throws -> String {
        guard let data = self.data(using: .utf8),
              let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            throw "Invalid input data"
        }

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesEncrypted: size_t = 0

        let status = keyData.withUnsafeBytes { keyBytes in
            ivData.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, keyData.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress, data.count,
                        &buffer, bufferSize,
                        &numBytesEncrypted
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw "Encryption failed with status: \(status)"
        }

        let encryptedData = Data(bytes: buffer, count: numBytesEncrypted)
        return encryptedData.base64EncodedString()
    }

    public func aesDecrypt(key: String, iv: String) throws -> String {
        guard let data = Data(base64Encoded: self),
              let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            throw "Invalid input data"
        }

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesDecrypted: size_t = 0

        let status = keyData.withUnsafeBytes { keyBytes in
            ivData.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, keyData.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress, data.count,
                        &buffer, bufferSize,
                        &numBytesDecrypted
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw "Decryption failed with status: \(status)"
        }

        let decryptedData = Data(bytes: buffer, count: numBytesDecrypted)
        return String(data: decryptedData, encoding: .utf8) ?? "Could not decrypt"
    }

    public func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    public func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    public func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
