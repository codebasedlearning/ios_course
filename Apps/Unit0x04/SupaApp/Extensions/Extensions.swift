// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

extension String {
    /// Extracts the part before '@' and capitalizes it if it starts with "user"
    var displayname: String {
        guard !self.isEmpty else { return "(Anonymous)" }
        guard let atIndex = self.firstIndex(of: "@") else { return self }
        let namePart = self[..<atIndex]
        return String(namePart)
    }
}

