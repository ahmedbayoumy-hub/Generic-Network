//
//  ViewController.swift
//  genericNetworkLayout
//
//  Created by Consultant on 12/28/22.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }

    
    
    struct Constants{
        static let usersUrl = URL(string: "https://jsonplaceholder.typicode.com/users")
        static let todolistUrl = URL(string: "")
    }
    
    private var table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        fetch()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    func fetch() {
        URLSession.shared.request(url: Constants.usersUrl, expecting: [User].self) {
            [weak self]result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self?.users = users
                    self?.table.reloadData()
                }
            case.failure(let error):
                print(error)
            }
            
        }
    }

}

//Models

struct User: Codable {
    let name: String
    let email: String
}




//Generic

extension URLSession {
    
    enum CustomError: Error {
        case invalidUrl
        case invalidData
    }
    
    func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            completion(.failure(CustomError.invalidUrl))
            return
        }
        
        let task = dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error{
                    completion(.failure(error))
                } else {
                    completion(.failure(CustomError.invalidData))
                }
                return
                    
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

