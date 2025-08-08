import Foundation
//
//  Event.swift
//  EventMe
//
//  Created by Eloy Beaucejour on 8/7/25.
//

struct Event: Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let host: String
    let locationName: String
    let latitude: Double
    let longitude: Double
    let date: Date
    let imageName: String
}
