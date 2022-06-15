//
//  WeatherDataModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 07.06.2022.
//

import Foundation

struct Weather: Decodable {
    let weather: [Day]?
    let main: CurrentWeather?
}

struct Day: Decodable {
    let description: String?
    let icon: String?
}

struct CurrentWeather: Decodable {
    let temp: Double?
//    let feels_like: Double
//    let temp_min: Double
//    let temp_max: Double
//    let pressure: Int
//    let humidity: Int
//    let sea_level: Int
//    let grnd_level: Int
}
