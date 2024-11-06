//
//  ContentView.swift
//  MetUCD
//
//  Created by CYL on 23/11/2023.
//

import Foundation
import CoreLocation

// MARK: - WeatherDataModel

struct WeatherDataModel {
    private(set) var geoLocationData: GeoLocationData?
    private(set) var weatherData: WeatherData?
    private(set) var pollutionData: PollutionData?
    private(set) var weatherForecastData: WeatherForecastData?
    private(set) var pollutionForecastData: PollutionForecastData?
    
    mutating func clear() {
        geoLocationData = nil
        weatherData = nil
        pollutionData = nil
        weatherForecastData = nil
        pollutionForecastData = nil
    }
    
    mutating func fetch(for coordinates: CLLocationCoordinate2D) async {
            clear()
            
            // Assuming you have methods in OpenWeatherMapAPI to fetch data using coordinates.
            weatherData = await OpenWeatherMapAPI.weather(at: coordinates)
            pollutionData = await OpenWeatherMapAPI.pollution(at: coordinates)
            weatherForecastData = await OpenWeatherMapAPI.weatherForecast(at: coordinates)
            pollutionForecastData = await OpenWeatherMapAPI.pollutionForecast(at: coordinates)
        }
    
    mutating func fetch(for location: String) async {
        clear()
        geoLocationData = await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1)
        guard let searchLocation = geoLocationData?.first?.location else { return }
        weatherData = await OpenWeatherMapAPI.weather(at: searchLocation)
        pollutionData = await OpenWeatherMapAPI.pollution(at: searchLocation)
        weatherForecastData = await OpenWeatherMapAPI.weatherForecast(at: searchLocation)
        pollutionForecastData = await OpenWeatherMapAPI.pollutionForecast(at: searchLocation)
    }
}


// MARK: - Partial support for OpenWeatherMap API 2.5 (free api access)

struct OpenWeatherMapAPI {
    private static let apiKey = "2b9a975c8bf478cfdd6f5235ed9e235e"
    private static let baseURL = "https://api.openweathermap.org/"

    // Async fetch from OpenWeatherMap
    private static func fetch<T: Decodable>(from apiString: String, asType type: T.Type) async throws -> T {
        guard let url = URL(string: "\(Self.baseURL)\(apiString)&appid=\(Self.apiKey)") else { throw NSError(domain: "Bad URL", code: 0, userInfo: nil) }
        let (data, _) =  try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    // MARK: - Public API
    
    static func geoLocation(for location: String, countLimit count: Int) async -> GeoLocationData? {
        let apiString = "geo/1.0/direct?q=\(location)&limit=\(count)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: GeoLocationData.self)
    }
    
    static func weather(at location: CLLocationCoordinate2D) async -> WeatherData? {
            let apiString = "data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric"
            return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
        }
    
    static func weather(at location: String) async -> WeatherData? {
        let apiString = "data/2.5/weather?q=\(location)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
    }
    
    static func weather(forCoorfinates coordinates: CLLocationCoordinate2D) async -> WeatherData? {
            let apiString = "data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric"
            return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
        }
    
    static func weatherForecast(at location: CLLocationCoordinate2D) async -> WeatherForecastData? {
        let apiString = "data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherForecastData.self)
    }

    static func weatherForecast(at location: String) async -> WeatherForecastData? {
        let apiString = "data/2.5/forecast?q=\(location)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherForecastData.self)
    }
    
    static func weatherForecast(forCoorfinates coordinates: CLLocationCoordinate2D) async -> WeatherData? {
            let apiString = "data/2.5/forecast?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric"
            return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
        }
    
    static func pollution(at location: CLLocationCoordinate2D) async -> PollutionData? {
        let apiString = "data/2.5/air_pollution?lat=\(location.latitude)&lon=\(location.longitude)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: PollutionData.self)
    }
    
    static func pollutionForecast(at location: CLLocationCoordinate2D) async -> PollutionForecastData? {
        let apiString = "data/2.5/air_pollution/forecast?lat=\(location.latitude)&lon=\(location.longitude)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: PollutionForecastData.self)
    }
    
    static func pollutionForecast(forCoorfinates coordinates: CLLocationCoordinate2D) async -> WeatherData? {
            let apiString = "data/2.5/air_pollution?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric"
            return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
        }
        
}


// MARK: - GeoLocationData

typealias GeoLocationData = [GeoLocation]


// MARK: - GeoLocation

struct GeoLocation: Codable{
    let name: String // Name of the found location
    let localNames: [String: String]? // Name of the found location in different languages. The list of names can be different for different locations
    let lat, lon: Double // Geographical coordinates of the found location (latitude, longitude)
    let country: String // Country of the found location
    let state: String? // (where available) State of the found location
    
    var location: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lon) }
}

// MARK: - WeatherData

struct WeatherData: Codable{
    let coord: Coord // lat and lon of the location
    let weather: [Weather] // weather conditions
    let base: String // Internal parameter
    let main: Main // weather data
    let visibility: Int // visibility
    let wind: Wind? // wind details
    let cloud: Clouds? // clouds details
    let rain: Rain? // rain details
    let snow: Snow? // snow details
    let dt: Int // datetime
    let sys: Sys // system
    let timezone: Int // timezone identifier
    let id: Int // city id
    let name: String // city name
    let cod: Int // Internal parameter
}

// MARK: - Coord
struct Coord: Codable{
    let lon: Double
    let lat: Double
}

// MARK: - Weather
struct Weather: Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Main
struct Main: Codable{
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
}

// MARK: - Wind
struct Wind: Codable{
    let speed: Double
    let deg: Int
    let gust: Double?
}

// MARK: - Cloud
struct Clouds: Codable{
    let all: Int
}

// MARK: - Rain
struct Rain: Codable{
    // Rain volume for the last 1 hour/ 3 hours, where is available
    private enum CodingKeys: String, CodingKey{
        case rain_1h = "1h"
        case rain_3h = "3h"
    }
    let rain_1h: Double?
    let rain_3h: Double?
}

// MARK: - Snow
struct Snow: Codable{
    // Snow volume for the last 1 hour/ 3 hours, where is available
    private enum CodingKeys: String, CodingKey{
        case snow_1h = "1h"
        case snow_3h = "3h"
    }
    let snow_1h: Double?
    let snow_3h: Double?
}

// MARK: - System
struct Sys: Codable{
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

// MARK: - PollutionData
struct PollutionData: Codable{
    let coord: Coord
    let list: [Pollution]
}

// MARK: - PollutionData List
struct Pollution: Codable{
    let dt: Int
    let main: AirQualityIndex
    let components: [Concentration: Double]
    enum CodingKeys: String, CodingKey {
            case dt, main, components
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dt = try container.decode(Int.self, forKey: .dt)
            main = try container.decode(AirQualityIndex.self, forKey: .main)

            // Decode the components as a [String: Double] dictionary
            let stringDictionary = try container.decode([String: Double].self, forKey: .components)

            // Convert the [String: Double] dictionary to [Concentration: Double]
            var concentrationDictionary = [Concentration: Double]()
            for (key, value) in stringDictionary {
                guard let concentration = Concentration(rawValue: key) else {
                    throw DecodingError.dataCorruptedError(forKey: .components,
                                                          in: container,
                                                          debugDescription: "Invalid concentration key")
                }
                concentrationDictionary[concentration] = value
            }
            components = concentrationDictionary
        }
}

// MARK: - Pollution Main
struct AirQualityIndex: Codable, CustomStringConvertible{
    let aqi: Int
    var description: String{
        switch aqi {
        case 1: "Good"
        case 2: "Fair"
        case 3: "Moderate"
        case 4: "Poor"
        case 5: "Very Poor"
        default:
            "Air Pollution Qulity : \(aqi)"
        }
    }
}

// MARK: - Concentration
enum Concentration: String, Codable, CustomStringConvertible {
    case co = "co"
    case no = "no"
    case no2 = "no2"
    case o3 = "o3"
    case so2 = "so2"
    case pm2_5 = "pm2_5"
    case pm10 = "pm10"
    case nh3 = "nh3"
    var description: String {
           self.rawValue.uppercased().replacingOccurrences(of: "_", with: ".")
       }
}

// MARK: - WeatherForecastData
struct WeatherForecastData: Codable{
    let cod: String
    let message: Int
    let cnt: Int
    var list: [WeatherForecast]
    let city: City
    
    var maxTemp: Double? {
            list.map({ (time: Date(timeIntervalSince1970: TimeInterval($0.dt)), temp: $0.main.tempMax) })
                .filter({ $0.time.timeIntervalSinceNow <= TimeInterval(86400) }).max(by: { $0.temp < $1.temp })?.temp
        }
        
        var minTemp: Double? {
            list.map({ (time: Date(timeIntervalSince1970: TimeInterval($0.dt)), temp: $0.main.tempMin) })
                .filter({ $0.time.timeIntervalSinceNow <= TimeInterval(86400) }).max(by: { $0.temp > $1.temp })?.temp
        }
                
        var fiveDayForecast: [DayForecast] {
            list.sorted(by: { $0.dt < $1.dt }).map({ $0.dayForecast }).orderedByDay
        }
}

extension Array where Element == DayForecast {
    var orderedByDay: [DayForecast] {
        let reordered = DayForecast.reorder(byDay: self)
        let (minT, maxT) = (reordered.minT, reordered.maxT)
        return reordered.map {
            var dayForecast = $0
            dayForecast.clip = (($0.minT - minT) / (maxT - minT), (maxT - $0.maxT) / (maxT - minT))
            return dayForecast
        }
    }
    var minT: Double { self.map({ $0.minT }).min() ?? .nan }
    var maxT: Double { self.map({ $0.maxT }).max() ?? .nan }
}

// MARK: - City
struct City: Codable{
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - WeatherForecast
struct WeatherForecast: Codable{
    let dt: Int
    var date: Date { Date(timeIntervalSince1970: TimeInterval(dt)) }
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind?
    let cloud: Clouds?
    let rain: Rain?
    let snow: Snow?
    let sys: Sys
    let pop: Double
    let dtTxt: String
    
    var dayForecast: DayForecast {
            var forecast = DayForecast(date: date, minT: main.temp, maxT: main.temp)
            forecast.icons.append((date, weather.first?.icon))
            if let timeStamp = sys.sunrise {
                forecast.sunrise = Date(timeIntervalSince1970: TimeInterval(timeStamp))
            }
            return forecast
        }
}

struct DayForecast{
    var date: Date
        var minT: Double
        var maxT: Double
        var icons = [(date: Date?, img: String?)]()
        var sunrise: Date?
        var isToday: Bool { Calendar.current.isDateInToday(date) }
        var clip: (leading: Double, trailing: Double) = (0, 0)

        static func reorder(byDay sortedList: [Self]) -> [Self] {
            var output = [Self]()
            var date = Date(timeIntervalSince1970: 0)

            // list of forcast data
            for data in sortedList {
                if !Calendar.current.isDate(date, inSameDayAs: data.date) {
                    date = data.date
                    output.append(data)
                } else {
                    var lastDay = output.removeLast()
                    lastDay.minT = lastDay.minT < data.minT ? lastDay.minT : data.minT
                    lastDay.maxT = lastDay.maxT > data.maxT ? lastDay.maxT : data.maxT
                    lastDay.icons.append(contentsOf: data.icons)
                    output.append(lastDay)
                }
            }
            
            // first day
            if var item = output.first {
                let padCount = 8 - item.icons.count
                if padCount > 0 {
                    var padding = [(Date?, String?)].init(repeating: (nil, nil), count: padCount)
                    padding.append(contentsOf: item.icons)
                    item.icons = padding
                    output[0] = item
                }
            }
            
            // last day
            if var item = output.last {
                let padCount = 8 - item.icons.count
                if padCount > 0 {
                    var padding = [(Date?, String?)].init(repeating: (nil, nil), count: padCount)
                    padding.insert(contentsOf: item.icons, at: 0)
                    item.icons = padding
                    output.removeLast()
                    output.append(item)
                }
            }

            return output
        }
}

// MARK: - PollutionForecastData
struct PollutionForecastData: Codable{
    let coord: Coord
    let list: [Pollution]
    
    var data: [(date: Date, aqi: AirQualityIndex)] {
           list.map { (Date(timeIntervalSince1970: TimeInterval($0.dt)), $0.main) }
       }
}

internal extension Double {
    var tempString: String { "\(Int(self.rounded()))°" }
}
