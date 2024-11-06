//
//  MetUCDApp.swift
//  MetUCD
//
//  Created by CYL on 23/11/2023.
//

import SwiftUI

@main
struct MetUCDApp: App {
    let weatherViewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView(weatherViewModel: weatherViewModel)
        }
    }
}
