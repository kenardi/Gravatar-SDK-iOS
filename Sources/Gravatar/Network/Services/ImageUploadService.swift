import Foundation
import UIKit

/// A service to perform uploading images to Gravatar.
///
/// This is the default type which implements ``ImageUploader``..
/// Unless specified otherwise, `ImageUploadService` will use a `URLSession` based `HTTPClient`.
struct ImageUploadService: ImageUploader {
    private let client: HTTPClient

    init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    @discardableResult
    func uploadImage(_ image: UIImage, accountId: AccountIdentifier) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, accountId: accountId)
    }

    private func uploadImage(data: Data, accountId: AccountIdentifier) async throws -> URLResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary).settingAuthorizationHeaderField(with: accountId.accessToken)
        let body = imageUploadBody(with: data, account: accountId.email, boundary: boundary)
        do {
            let response = try await client.uploadData(with: request, data: body)
            return response
        } catch let error as HTTPClientError {
            throw ImageUploadError.responseError(reason: error.map())
        } catch {
            throw ImageUploadError.responseError(reason: .unexpected(error))
        }
    }
}

private func imageUploadBody(with imageData: Data, account: String, boundary: String) -> Data {
    enum UploadParameters {
        static let contentType = "application/octet-stream"
        static let filename = "profile.png"
        static let imageKey = "filedata"
        static let accountKey = "account"
    }

    var body = Data()

    // Image Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\(UploadParameters.imageKey); ")
    body.append("filename=\(UploadParameters.filename)\r\n")
    body.append("Content-Type: \(UploadParameters.contentType);\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")

    // Account Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"\(UploadParameters.accountKey)\"\r\n\r\n")
    body.append("\(account)\r\n")

    // EOF!
    body.append("--\(boundary)--\r\n")

    return body as Data
}

extension Data {
    fileprivate mutating func append(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            append(data)
        }
    }
}

extension URLRequest {
    fileprivate static func imageUploadRequest(with boundary: String) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
}
