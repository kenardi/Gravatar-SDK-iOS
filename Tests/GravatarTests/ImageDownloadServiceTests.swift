@testable import Gravatar
import TestHelpers
import XCTest

final class ImageDownloadServiceTests: XCTestCase {
    func testFetchImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageDownloadService(with: sessionMock, cache: TestImageCache())

        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)
        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testImageProcessingError() async throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        do {
            _ = try await service.fetchImage(with: imageURL, processingMethod: .custom(processor: FailingImageProcessor()))
            XCTFail()
        } catch ImageFetchingError.imageProcessorFailed {
            // success
        } catch {
            XCTFail()
        }
    }

    func testFetchCatchedImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)
        let setImageCallsCount = cache.setImageCallsCount
        let setTaskCallCount = cache.setTaskCallsCount
        let getImageCallsCount = cache.getImageCallsCount
        let request = await sessionMock.request
        let callsCount = await sessionMock.callsCount
        XCTAssertEqual(setImageCallsCount, 1)
        XCTAssertEqual(setTaskCallCount, 1)
        XCTAssertEqual(getImageCallsCount, 3)
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testSimultaneousFetchShouldOnlyTriggerOneNetworkRequest() async throws {
        let imageURL = URL(string: "https://example.com/image.png")!

        let mockImageData = UIImage(systemName: "iphone.gen2")!.pngData()!

        let sessionMock = URLSessionMock(
            returnData: mockImageData,
            response: HTTPURLResponse.successResponse(with: imageURL)
        )

        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        let expectation = XCTestExpectation(description: "Image fetches should complete")

        // When
        // Start simultaneous fetches
        let fetchTask1 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask2 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask3 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask4 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask5 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }

        // Then
        let result1 = try await fetchTask1.value
        let result2 = try await fetchTask2.value
        let result3 = try await fetchTask3.value
        let result4 = try await fetchTask4.value
        let result5 = try await fetchTask5.value

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 0.5)

        // Assert that all fetches return the same image
        XCTAssertEqual(result1.image.pngData(), mockImageData)
        XCTAssertEqual(result2.image.pngData(), mockImageData)
        XCTAssertEqual(result3.image.pngData(), mockImageData)
        XCTAssertEqual(result4.image.pngData(), mockImageData)
        XCTAssertEqual(result5.image.pngData(), mockImageData)

        // Assert that all fetches attempted to read from the cache
        XCTAssertEqual(cache.messageCount(type: .get), 5)

        // Assert that only one fetch set an `.inProgress` CacheEntry
        XCTAssertEqual(cache.messageCount(type: .inProgress, forKey: imageURL.absoluteString), 1)

        // Assert that only one fetch set an `.ready` CacheEntry
        XCTAssertEqual(cache.messageCount(type: .ready, forKey: imageURL.absoluteString), 1)
    }
}

private func imageDownloadService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = ImageDownloadService(client: client, cache: cache)
    return service
}
