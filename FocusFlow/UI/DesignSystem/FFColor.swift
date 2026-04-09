import SwiftUI

enum FFColor {
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)

    static let brand = Color(red: 0.36, green: 0.55, blue: 1.00)
    static let brand2 = Color(red: 0.55, green: 0.36, blue: 1.00)

    static let gradient = LinearGradient(
        colors: [brand, brand2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

