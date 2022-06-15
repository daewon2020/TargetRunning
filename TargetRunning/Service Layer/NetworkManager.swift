//
//  NetworkManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 07.06.2022.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class NetworkManager {
    static var shared = NetworkManager()
    private var urlString = "https://api.openweathermap.org/data/2.5/weather?appid=91c9f997982ae2c3a682b6ed914653f0&units=metric"
    private let urlIcon = "https://openweathermap.org/img/wn/"
    private init() {}
    
    func fetchWeatherData(lon: Double, lat: Double, comletion: @escaping (Result<Weather, NetworkError>) -> ()) {
        urlString += "&lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else {
            comletion(.failure(.invalidURL))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                comletion(.failure(.noData))
                return
            }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    comletion(.success(weather))
                }
            } catch {
                comletion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
    func fetchWeatherIcon(iconName: String, completion: @escaping (Data)->()) {
        guard let url = URL(string: urlIcon + iconName + "@2x.png") else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
}
