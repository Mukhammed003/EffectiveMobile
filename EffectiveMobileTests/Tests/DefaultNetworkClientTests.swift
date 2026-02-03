import XCTest
@testable import EffectiveMobile

final class DefaultNetworkClientTests: XCTestCase {

    private var client: DefaultNetworkClient!
    private var session: URLSession!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self] 
        session = URLSession(configuration: config)
        client = DefaultNetworkClient(session: session)
    }

    override func tearDown() {
        client = nil
        session = nil
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.responseError = nil
        super.tearDown()
    }

    func testSend_Success() {
        let expectedData = "{\"test\":1}".data(using: .utf8)
        MockURLProtocol.stubResponseData = expectedData
        MockURLProtocol.responseError = nil

        let expectation = self.expectation(description: "Completion called")

        let request = MockRequest()
        _ = client.send(request: request) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, expectedData)
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSend_Failure() {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.responseError = NSError(domain: "Test", code: 1)

        let expectation = self.expectation(description: "Completion called")

        let request = MockRequest()
        _ = client.send(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure:
                XCTAssertTrue(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mocks

private class MockRequest: NetworkRequest {
    var endpoint: URL? { URL(string: "https://mock.test") }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

// URLProtocol mock
private class MockURLProtocol: URLProtocol {

    static var stubResponseData: Data?
    static var responseError: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.responseError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            // Отправляем корректный HTTPURLResponse
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = MockURLProtocol.stubResponseData {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

