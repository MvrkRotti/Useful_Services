import Foundation

struct UserResults: Decodable {
    let results: [User]
    
    struct User: Decodable {
        var gender: String
        var name: Name
        var email: String
        var picture: Picture
        
        struct Name: Decodable {
            var title: String
            var first: String
            var last: String
        }
        
        struct Picture: Decodable {
            var large: String
        }
    }
}

class NetworkServiceWithCompletions {
    static let shared = NetworkServiceWithCompletions(); private init() {}
    
    private func createURL() -> URL? {
        let tunnel = "https://"
        let server = "randomuser.me"
        let endPoint = "/api"
        let getParams = ""
        let urlString = tunnel + server + endPoint + getParams
        
        let url = URL(string: urlString)
        return url
    }
    
    func fetchData(completion: @escaping (Result<UserResults, Error>) -> ()) {
        guard let url = createURL() else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                if let error {
                    completion(.failure(error))
                }
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let usersData = try decoder.decode(UserResults.self, from: data)
                completion(.success(usersData))
            } catch {
                completion(.failure(NetworkingError.invalidData))
            }
        }.resume()
        
    }
}

enum NetworkingError: Error {
    case badUrl, badRequest, badResponse, invalidData
}

//Применение в классе

class ViewController: UIViewController {
    var user: UserResults.User?
    private let networkService = NetworkServiceWithCompletions.shared
    
    func fetchUser() {
        networkService.fetchData { result in
            switch result {
            case .success(let userData):
                let user = userData.results[0]
                self.user = user
                DispatchQueue.main.async {
                    self.updateUI(with: user)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
