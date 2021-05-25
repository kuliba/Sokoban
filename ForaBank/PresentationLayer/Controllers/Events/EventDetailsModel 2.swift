// EventDetails.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let eventDetails = try EventDetails(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.eventDetailsTask(with: url) { eventDetails, response, error in
//     if let eventDetails = eventDetails {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseEventDetails { response in
//     if let eventDetails = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - EventDetails
struct EventDetails: Codable {
    var id: Int?
    var siteURL: String?
    var publicationDate: Int?
    var slug, title, eventDetailsDescription, bodyText: String?
    var isEditorsChoice: Bool?
    var favoritesCount: Int?
    var genres: [Genre]?
    var commentsCount: Int?
    var originalTitle, locale, country: String?
    var year: Int?
    var language: String?
    var runningTime: Int?
    var budgetCurrency: String?
    var budget: Int?
    var mpaaRating: String?
    var ageRestriction: String?
    var stars, director, writer, awards: String?
    var trailer: String?
    var images: [PosterDetails]?
    var poster: PosterDetails?
    var url: String?
    var imdbURL: String?
    var imdbRating: Double?
    var disableComments: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case siteURL = "site_url"
        case publicationDate = "publication_date"
        case slug, title
        case eventDetailsDescription = "description"
        case bodyText = "body_text"
        case isEditorsChoice = "is_editors_choice"
        case favoritesCount = "favorites_count"
        case genres
        case commentsCount = "comments_count"
        case originalTitle = "original_title"
        case locale, country, year, language
        case runningTime = "running_time"
        case budgetCurrency = "budget_currency"
        case budget
        case mpaaRating = "mpaa_rating"
        case ageRestriction = "age_restriction"
        case stars, director, writer, awards, trailer, images, poster, url
        case imdbURL = "imdb_url"
        case imdbRating = "imdb_rating"
        case disableComments = "disable_comments"
    }
}

// MARK: EventDetails convenience initializers and mutators

extension EventDetails {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EventDetails.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: Int?? = nil,
        siteURL: String?? = nil,
        publicationDate: Int?? = nil,
        slug: String?? = nil,
        title: String?? = nil,
        eventDetailsDescription: String?? = nil,
        bodyText: String?? = nil,
        isEditorsChoice: Bool?? = nil,
        favoritesCount: Int?? = nil,
        genres: [Genre]?? = nil,
        commentsCount: Int?? = nil,
        originalTitle: String?? = nil,
        locale: String?? = nil,
        country: String?? = nil,
        year: Int?? = nil,
        language: String?? = nil,
        runningTime: Int?? = nil,
        budgetCurrency: String?? = nil,
        budget: Int?? = nil,
        mpaaRating: String?? = nil,
        ageRestriction: String?? = nil,
        stars: String?? = nil,
        director: String?? = nil,
        writer: String?? = nil,
        awards: String?? = nil,
        trailer: String?? = nil,
        images: [PosterDetails]?? = nil,
        poster: PosterDetails?? = nil,
        url: String?? = nil,
        imdbURL: String?? = nil,
        imdbRating: Double?? = nil,
        disableComments: Bool?? = nil
    ) -> EventDetails {
        return EventDetails(
            id: id ?? self.id,
            siteURL: siteURL ?? self.siteURL,
            publicationDate: publicationDate ?? self.publicationDate,
            slug: slug ?? self.slug,
            title: title ?? self.title,
            eventDetailsDescription: eventDetailsDescription ?? self.eventDetailsDescription,
            bodyText: bodyText ?? self.bodyText,
            isEditorsChoice: isEditorsChoice ?? self.isEditorsChoice,
            favoritesCount: favoritesCount ?? self.favoritesCount,
            genres: genres ?? self.genres,
            commentsCount: commentsCount ?? self.commentsCount,
            originalTitle: originalTitle ?? self.originalTitle,
            locale: locale ?? self.locale,
            country: country ?? self.country,
            year: year ?? self.year,
            language: language ?? self.language,
            runningTime: runningTime ?? self.runningTime,
            budgetCurrency: budgetCurrency ?? self.budgetCurrency,
            budget: budget ?? self.budget,
            mpaaRating: mpaaRating ?? self.mpaaRating,
            ageRestriction: ageRestriction ?? self.ageRestriction,
            stars: stars ?? self.stars,
            director: director ?? self.director,
            writer: writer ?? self.writer,
            awards: awards ?? self.awards,
            trailer: trailer ?? self.trailer,
            images: images ?? self.images,
            poster: poster ?? self.poster,
            url: url ?? self.url,
            imdbURL: imdbURL ?? self.imdbURL,
            imdbRating: imdbRating ?? self.imdbRating,
            disableComments: disableComments ?? self.disableComments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Genre.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let genre = try Genre(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.genreTask(with: url) { genre, response, error in
//     if let genre = genre {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseGenre { response in
//     if let genre = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Genre
struct Genre: Codable {
    var id: Int?
    var name, slug: String?
}

// MARK: Genre convenience initializers and mutators

extension Genre {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Genre.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: Int?? = nil,
        name: String?? = nil,
        slug: String?? = nil
    ) -> Genre {
        return Genre(
            id: id ?? self.id,
            name: name ?? self.name,
            slug: slug ?? self.slug
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Poster.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let poster = try Poster(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.posterTask(with: url) { poster, response, error in
//     if let poster = poster {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePoster { response in
//     if let poster = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Poster
struct PosterDetails: Codable {
    var image: String?
    var source: SourceDetails?
}

// MARK: Poster convenience initializers and mutators

extension PosterDetails {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PosterDetails.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        image: String?? = nil,
        source: SourceDetails?? = nil
    ) -> PosterDetails {
        return PosterDetails(
            image: image ?? self.image,
            source: source ?? self.source
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Source.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let source = try Source(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.sourceTask(with: url) { source, response, error in
//     if let source = source {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseSource { response in
//     if let source = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Source
struct SourceDetails: Codable {
    var name: String?
    var link: String?
}

// MARK: Source convenience initializers and mutators

extension SourceDetails {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SourceDetails.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String?? = nil,
        link: String?? = nil
    ) -> Source {
        return Source(
            name: name ?? self.name,
            link: link ?? self.link
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// JSONSchemaSupport.swift

import Foundation

// MARK: - Helper functions for creating encoders and decoders



// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func eventDetailsTask(with url: URL, completionHandler: @escaping (EventDetails?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

// MARK: - Alamofire response handlers


