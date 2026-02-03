// MARK: - Network Task Protocol

import Foundation

protocol NetworkTask {
    func cancel()
}

// MARK: - Default Network Task Implementation

struct DefaultNetworkTask: NetworkTask {
    let dataTask: URLSessionDataTask
    
    func cancel() {
        dataTask.cancel()
    }
}
