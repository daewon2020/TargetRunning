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

class NetworkMaager {
    static var shared = NetworkMaager()
    private let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=54.35&lon=52.52&appid=91c9f997982ae2c3a682b6ed914653f0&units=metric"
    
    private init() {}
    
    func fetchWeatherData() {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                
            }
        }
    }
}
