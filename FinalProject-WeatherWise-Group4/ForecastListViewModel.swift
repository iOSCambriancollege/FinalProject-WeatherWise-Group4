//
//  ForecastListViewModel.swift
//  FinalProject-WeatherWise-Group4
//
//  Created by Majid Pawar on 2023-11-29.
//

import CoreLocation
import Foundation
import SwiftUI


class ForecastListViewModel: ObservableObject {
    
    @Published var forecasts: [ForecastViewModel] = []
    @AppStorage("location") var location: String = ""
    @AppStorage("system") var system: Int = 0 {
        didSet {
            for i in 0..<forecasts.count {
                forecasts[i].system = system
            }
        }
    }
    
    init() {
        if location != "" {
            getWeatherForecast()
        }
    }
    
    func getWeatherForecast() {
        let apiService = APIService.shared
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let lat = placemarks?.first?.location?.coordinate.latitude,
               let lon = placemarks?.first?.location?.coordinate.longitude {
                // Don't forget to use your own key
                        apiService.getJSON(urlString: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&appid=87db448e4dac72ac4fc7b9d5844fb89c",
                                           dateDecodingStrategy: .secondsSince1970) { (result: Result<Forecast,APIService.APIError>) in

                    switch result {
                    case .success(let forecast):
                        DispatchQueue.main.async {
                            self.forecasts = forecast.daily.map { ForecastViewModel(forecast: $0, system: self.system)}
                        }
                    case .failure(let apiError):
                        switch apiError {
                        case .error(let errorString):
                            print(errorString)
                        }
                    }
                }
            }
        }

    }
}
