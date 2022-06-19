//
//  WeatherDataModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 07.06.2022.
//

import Foundation

struct Weather: Decodable {
    let name: String?
    let weather: [Day]?
    let main: CurrentWeather?
}

struct Day: Decodable {
    let description: String?
    let icon: String?
}

struct CurrentWeather: Decodable {
    let temp: Double?
}
