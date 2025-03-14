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

struct Alignment: Decodable, Hashable {
    let horizontal: HorizontalAlignmentConstraint
    let vertical: VerticalAlignmentConstraint
    enum CodingKeys: CodingKey {
        case horizontal
        case vertical
    }
}

struct Position: Decodable, Hashable {
    enum Kind: Hashable {
        case center(Point)
        case origin(Point)
        case relative(Alignment)
    }

    let kind: Kind

    private enum CodingKeys: String, CodingKey {
        case center
        case origin
        case relative
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let centerVal = try container.decodeIfPresent(Point.self, forKey: .center) {
            kind = .center(centerVal)
        } else if let originVal = try container.decodeIfPresent(Point.self, forKey: .origin) {
            kind = .origin(originVal)
        } else if let alignmentVal = try container.decodeIfPresent(Alignment.self, forKey: .relative) {
            kind = .relative(alignmentVal)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.center,
                in: container,
                debugDescription: "Expected either 'center' or 'origin' in 'position' object."
            )
        }
    }
}
