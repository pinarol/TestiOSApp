import Foundation

enum VerticalAlignment: String, Decodable, Hashable {
    case top
    case center
    case bottom
}

enum HorizontalAlignment: String, Decodable, Hashable {
    case left
    case center
    case right
}

struct HorizontalAlignmentConstraint: Decodable, Hashable {
    let alignment: HorizontalAlignment
    let offset: Double // floating-point offset defined as proportions of the parent's width.

    enum CodingKeys: CodingKey {
        case alignment
        case offset
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.alignment = try container.decode(HorizontalAlignment.self, forKey: .alignment)
        self.offset = try container.decodeIfPresent(Double.self, forKey: .offset) ?? 0
    }
}

struct VerticalAlignmentConstraint :Decodable, Hashable {
    let alignment: VerticalAlignment
    let offset: Double // floating-point offset defined as proportions of the parent's height.

    enum CodingKeys: CodingKey {
        case alignment
        case offset
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.alignment = try container.decode(VerticalAlignment.self, forKey: .alignment)
        self.offset = try container.decodeIfPresent(Double.self, forKey: .offset) ?? 0
    }
}

struct Position: Decodable, Hashable {
    let horizontal: HorizontalAlignmentConstraint
    let vertical: VerticalAlignmentConstraint
    enum CodingKeys: CodingKey {
        case horizontal
        case vertical
    }
}
