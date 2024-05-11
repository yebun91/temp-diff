//
//  WeatherForecast.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import Foundation

struct WeatherForecast : Codable {
    var yesterday: [WeatherItem]
    var today: [WeatherItem]
}

struct WeatherItem : Codable {
    let baseDate: String
    let fcstTime: String
    let fcstValue: String
    let TMP: String
    let UUU: String
    let VEC: String
    let SKY: String
    let POP: String
    let PCP: String
    let SNO: String
    let VVV: String
    let WSD: String
    let PTY: String
    let WAV: String
    let REH: String
}
