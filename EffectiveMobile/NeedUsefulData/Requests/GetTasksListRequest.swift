import Foundation

// MARK: - Request for get users
struct GetTasksListRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        let components = URLComponents(string: RequestConstants.baseURL)
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
