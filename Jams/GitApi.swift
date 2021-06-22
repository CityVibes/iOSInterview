import Foundation
import RxSwift
import RealmSwift

struct GitApi {
    
    func fetchRepositories(since: Int? = nil) -> Observable<[Repository]> {
        return Observable.create { observer -> Disposable in
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.github.com"
            components.path = "/repositories"
            
            if let since = since {
                components.queryItems = [
                    URLQueryItem(name: "since", value: "\(since)")
                ]
            }
            
            let decoder = JSONDecoder()
            
            let task = URLSession.shared.dataTask(with: components.url!) {(data, response, error) in
                guard let data = data else { return }
                
                if let repositories = try? decoder.decode([Repository].self, from: data) {
                    observer.on(.next(repositories))
                }
            }

            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

struct Repository: Codable {
    let id: Int
    let full_name: String
}

class RealmRepository: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var full_name: String? = nil
}
