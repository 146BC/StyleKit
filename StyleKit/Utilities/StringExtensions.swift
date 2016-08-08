extension String {
    func capitalizeFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalizedString
        let other = String(characters.dropFirst())
        return first + other
    }
}