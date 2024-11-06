//
//  Persistence.swift
//  MetUCD
//
//  Created by CYL on 23/11/2023.
//

import SwiftUI
import Charts
import CoreLocation
import MapKit


// MARK: - Geo Section
struct GeoSection: View {
    let data: [WeatherViewModel.GeoDataKey: String]

    var body: some View {
        
        Section {
            HStack {
                Image("location").resizable().frame(width: 20, height: 20)
                Text(data[.location]!)
            }
            HStack {
                Image("sunrise").resizable().frame(width: 30, height: 30)
                Text(data[.sunrise]!)
                Text("(" + data[.sunriseLocal]! + ")").foregroundStyle(.gray)
                
                Image("sunset").resizable().frame(width: 30, height: 30)
                Text(data[.sunset]!)
                Text("(" + data[.sunsetLocal]! + ")").foregroundStyle(.gray)
            }
            HStack {
                Image("time").resizable().frame(width: 30, height: 30)
                Text(data[.timeOffset]!)
            }
        } header: {
            Text("Geo info")
        }
    }
}


// MARK: - Current Weather Section (min, max retrieved from 5 day forecast)
struct CurrentWeatherSection: View {
    let data: [WeatherViewModel.WeatherDataKey: String]
    
    var body: some View {
        
        Section {
            HStack {
                Image("temperature").resizable().frame(width: 20, height: 20)
                Text(data[.temp]!)
                if let low = data[.minTemp], let high = data[.maxTemp] {
                    Text("(L: " + low + " H: " + high + ")").foregroundStyle(.gray)
                }
                Image("temperature-feels-like").resizable().frame(width: 20, height: 20)
                Text("Feels \(data[.feelslike]!)")
            }
            if let clouds = data[.clouds] {
                HStack {
                    Image("cloud").resizable().frame(width: 20, height: 20)
                    Text(clouds)
                }
            }
            if let rain = data[.rain] {
                HStack {
                    Image("rain").resizable().frame(width: 20, height: 20)
                    Text(rain)
                }
            }
            if let snow = data[.snow] {
                HStack {
                    Image("snow").resizable().frame(width: 20, height: 20)
                    Text(snow)
                }
            }
            if let wind = data[.wind] {
                HStack {
                    Image("wind").resizable().frame(width: 30, height: 30)
                    Text(wind)
                }
            }
            HStack {
                Image("humidity").resizable().frame(width: 20, height: 20)
                Text(data[.humidity]!)
                
                Image( "pressure").resizable().frame(width: 20, height: 20)
                Text(data[.pressure]!)
            }
        } header: {
            if let description = data[.description] {
                Text("Weather: " + description)
            }
        }
    }
}

// MARK: - Simple Weather Data
struct SimpleWeatherData: View{
    let data: [WeatherViewModel.WeatherDataKey: String]
    var body: some View {
        HStack {
            Image("temperature").resizable().frame(width: 50, height: 50)
            Text(data[.temp]!)
        }
        HStack{
            if let description = data[.description] {
                Text( description)
            }
        }
        HStack{
            if let low = data[.minTemp], let high = data[.maxTemp] {
                Text("(L: " + low + " H: " + high + ")").foregroundStyle(.gray)
            }
        }
    }
}

// MARK: - Current Pollution Section
struct CurrentPollutionSection: View {
    let data: [WeatherViewModel.PollutionDataKey: Any]
    var vGridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if let components = data[.components] as? [(String, String)] {
            Section {
                VStack {
                    LazyVGrid(columns: vGridLayout, alignment: .center, spacing: 8) {
                        ForEach(components.indices, id: \.self) { index in
                            HStack {
                                Text(components[index].0)
                                    .foregroundStyle(.tint)
                                    .frame(width: 50, alignment: .trailing)
                                    .padding(0)
                                Text(components[index].1)
                                    .padding(0)
                                Spacer()
                            }
                            .padding(.bottom, 5)
                        }
                        .font(.callout)
                    }
                    HStack {
                        Spacer()
                        Text("(units: μg/m3)").font(.caption).foregroundStyle(.gray)
                    }
                }
            } header: {
                Text((data[.description] as? String) ?? "")
            }
        }
    }
}


// MARK: - Forecast Section
struct ForecastSection: View {
    let data: WeatherForecastData
    
    var body: some View {
        Section {
            let fiveDayForecast = data.fiveDayForecast
            ForEach(fiveDayForecast.indices, id: \.self) { index  in
                let forecast = fiveDayForecast[index]
                VStack(alignment: .leading) {
                    DayAndTemperatureRow(forecast: forecast)
                    DayWeatherIconRow(icons: forecast.icons)
                }
            }
        } header: {
            Text("5 day forecast")
        }
    }
}


struct DayAndTemperatureRow: View {
    let forecast: DayForecast

    var body: some View {
        HStack {
            Text(forecast.isToday ? "Today" : forecast.date.dayStr).foregroundStyle(.tint)
            Image(systemName: "thermometer").foregroundStyle(.gray)
            Text("(L: \(forecast.minT.tempString) H: \(forecast.maxT.tempString))").foregroundStyle(.gray)
        }
    }
}

struct DayWeatherIconRow: View {
    let icons: [(date: Date?, img: String?)]

    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { index in
                let icon = icons[index]
                let label = icon.date?.hourStr ?? ""
                VStack(spacing: 0) {
                    Text(label).font(.footnote)
                    if let img = icon.img {
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(img)@2x.png")) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }.background(RoundedRectangle(cornerRadius: 5).foregroundStyle(Color.init(white: 0.8, opacity: 0.5))).aspectRatio(1, contentMode: .fit)
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }
}


// MARK: - Pollution Forecast Chart

struct PollutionChartView: View {
    let data: [(date: Date, aqi: AirQualityIndex)]
    
    var body: some View {
        Section {
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Date", data[index].date),
                        y: .value("API", data[index].aqi.aqi)
                    )
                    .foregroundStyle(.tint)
                }
            }
            .frame(height: 180)
            .padding()
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 24)) { date in
                    AxisValueLabel(format: .dateTime.weekday(.short))
                }
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            let aqi = AirQualityIndex(aqi: intValue)
                            Text("\(aqi.description)")
                        }
                    }
                }
            }.padding([.leading, .trailing], -20)
        } header: {
            Text("Air Pollution Index Forecast")
        }
    }
}


// MARK: - Detailed Weather View

struct DetailedWeatherView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
//    @FocusState private var isFocused: Bool
    
    var body: some View {
        Form {
            Section {
                VStack {
            if let data = weatherViewModel.geoData {
                GeoSection(data: data)
            }
            if let data = weatherViewModel.weatherData {
                CurrentWeatherSection(data: data)
            }
            if let data = weatherViewModel.pollutionData {
                CurrentPollutionSection(data: data)
            }
            if let data = weatherViewModel.weatherForecastData {
                ForecastSection(data: data)
            }
            if let data = weatherViewModel.pollutionForecastData?.data {
                PollutionChartView(data: data)
            }
        }
    }
}
        
// MARK: - Map View
struct WeatherView: View {
    @StateObject var weatherViewModel = WeatherViewModel()
    @State private var mapRegion: MKCoordinateRegion
    @State private var showingLocationDetails = false
    
    init() {
        // Initialize the map region to a default value
        _mapRegion = State(initialValue: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.3069, longitude: -157.8583),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))
    }
    var body: some View {
            ZStack {
                Map(coordinateRegion: $mapRegion, annotationItems: [weatherViewModel.userLocation].compactMap { $0 }) { location in
                    MapAnnotation(coordinate: location) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                self.showingLocationDetails = true
                                // Fetch weather data for this location
                                weatherViewModel.fetch(for: location)
                            }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {}

                if showingLocationDetails {
                    locationDetailsView
                        .transition(.slide)
                        .animation(.easeInOut)
                }

                VStack {
                    if isSearching {
                        searchBar.padding()
                    }
                    Spacer()
                    locationButton.padding()
                }
            }
            .sheet(isPresented: $showingLocationDetails) {
                DetailedWeatherView(weatherViewModel: weatherViewModel)
            }
        }
    var locationButton: some View {
            Button(action: {
                mapRegion.center = weatherViewModel.userLocation ?? CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            }) {
                Image(systemName: "location.fill")
                    .padding()
                    .background(Circle().fill(Color.white))
                    .shadow(radius: 5)
            }
        }
    
    var searchBar: some View {
            HStack {
                TextField(text: $weatherViewModel.namedLocation) {
                    Text("Enter location e.g. Dublin, IE")
                }
                .disableAutocorrection(true)
                .focused($isFocused, equals: true)
                .onSubmit { weatherViewModel.fetchData() }
                .onChange(of: isFocused, initial: true) { oldValue, newValue in
                    if newValue {
                        weatherViewModel.namedLocation = ""
                    }
                }
            }
        }
    }
}
}

// MARK: - Extentions

extension Date {
    private static var formatter = DateFormatter()
    var hourStr: String {
        let formatter = Self.formatter
        Self.formatter.dateFormat = "H'H'"
        return formatter.string(from: self)
    }
    
    var dayStr: String {
        let formatter = Self.formatter
        Self.formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    static var utcOffset: TimeInterval {
        Double(TimeZone.current.secondsFromGMT(for: Date()))
    }
}


extension CLLocationCoordinate2D {
    var description: String {
        let latString = latitude.dmsString + " " + (latitude >= 0 ? "N" : "S")
        let lonString = longitude.dmsString + " " + (longitude >= 0 ? "E" : "W")
        return "\(latString), \(lonString)"
    }
}


extension Coord {
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension Double {
    var dmsString: String {
        let absoluteLatitude = abs(self)
        let d = Int(absoluteLatitude)
        let remainingMinutes = (absoluteLatitude - Double(d)) * 60
        let m = Int(remainingMinutes)
        let s = Int((remainingMinutes - Double(m)) * 60)
        return String(format: "%d°%d'%d\"", d, m, s)
    }
}


// MARK: - Preview

#Preview {
    WeatherView(weatherViewModel: WeatherViewModel())
}
