// SPDX-License-Identifier: MIT
import Foundation
import Security
import CryptoKit

public struct GitHubAppAuth {
    let appID: String
    let privateKeyPEM: String

    func generateJWT() throws -> String {
        let header: [String: String] = ["alg": "RS256", "typ": "JWT"]
        let now = Int(Date().timeIntervalSince1970)
        let payload: [String: Any] = [
            "iss": appID,
            "iat": now,
            "exp": now + 600  // 10 minutes
        ]

        let headerData = try JSONSerialization.data(withJSONObject: header)
        let payloadData = try JSONSerialization.data(withJSONObject: payload)

        let headerBase64 = headerData.base64URLEncodedString()
        let payloadBase64 = payloadData.base64URLEncodedString()

        let message = "\(headerBase64).\(payloadBase64)"

        let signature = try signMessage(message, with: privateKeyPEM)
        let signatureBase64 = signature.base64URLEncodedString()

        return "\(message).\(signatureBase64)"
    }

    private func signMessage(_ message: String, with pem: String) throws -> Data {
        guard let privateKeyData = pemToDER(pem) else {
            throw NSError(domain: "GitHubAppAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid PEM"])
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(privateKeyData as CFData, attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }

        let digest = SHA256.hash(data: message.data(using: .utf8)!)
        let digestData = Data(digest)

        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureDigestPKCS1v15SHA256,
            digestData as CFData,
            &error
        ) else {
            throw error!.takeRetainedValue() as Error
        }

        return signature as Data
    }

    private func pemToDER(_ pem: String) -> Data? {
        let pemString = pem
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----\n", with: "")
            .replacingOccurrences(of: "\n-----END RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        return Data(base64Encoded: pemString)
    }

    static func generateTestKeyPair() throws -> (privatePEM: String, publicPEM: String) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]

        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else {
            throw NSError(domain: "Security", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate key"])
        }

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(
                domain: "Security",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to derive public key"]
            )
        }

        let privData = SecKeyCopyExternalRepresentation(privateKey, nil)! as Data
        let pubData = SecKeyCopyExternalRepresentation(publicKey, nil)! as Data

        let privHeader = "-----BEGIN RSA PRIVATE KEY-----\n"
        let privFooter = "\n-----END RSA PRIVATE KEY-----"
        let privPEM = privHeader + privData.base64EncodedString(options: .lineLength64Characters) + privFooter

        let pubHeader = "-----BEGIN RSA PUBLIC KEY-----\n"
        let pubFooter = "\n-----END RSA PUBLIC KEY-----"
        let pubPEM = pubHeader + pubData.base64EncodedString(options: .lineLength64Characters) + pubFooter

        return (privPEM, pubPEM)
    }

    @available(macOS 12.0, *)
    func installationToken(installationID: String) async throws -> String {
        let jwt = try generateJWT()
        let url = URL(string: "https://api.github.com/app/installations/\(installationID)/access_tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["token"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return token
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
