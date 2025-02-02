
import Foundation

class NetworkServiceWithAsync {
    static let shared = NetworkServiceWithAsync(); private init() {}
    
    private func createURL() -> URL? {
        let tunnel = "https://"
        let server = "randomuser.me"
        let endPoint = "/api"
        let getParams = ""
        let urlString = tunnel + server + endPoint + getParams
        
        let url = URL(string: urlString)
        return url
    }
    
    func fetchData() async throws -> UserResults {
        guard let url = createURL() else { throw NetworkingError.badUrl }
        
        let response = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result = try decoder.decode(UserResults.self, from: response.0)
        return result
    }
}

//Применение в классе

class ViewController: UIViewController {
    var user: UserResults.User?
    private let networkService = NetworkServiceWithAsync.shared
    
    Task {
        let result = try await self.networkService.fetchData()
        self.user = result.results[0]
        self.updateUI(with: user)
    }
}

