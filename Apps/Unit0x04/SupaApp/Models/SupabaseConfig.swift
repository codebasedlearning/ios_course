// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

// SECURITY: these credentials must NOT be committed to version control in a real project.
//    The correct approach is:
//      1. Add a .xcconfig file (e.g. Secrets.xcconfig) with SUPABASE_URL and SUPABASE_KEY entries
//      2. Reference it in the target's build settings under "Configurations"
//      3. Expose them in Info.plist as entries that read from $(SUPABASE_URL) etc.
//      4. Read here via Bundle.main.infoDictionary
//      5. Add Secrets.xcconfig to .gitignore
//
//    For this course project the values are kept here for simplicity, but
//    treat any production key the same way you'd treat a password.

struct SupabaseConfig {
    static let url    = URL(string: "https://uxadpjjumbfqzhmwhitv.supabase.co")!
    static let __anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5cG5lb2t6Znltb25ub3hwZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxOTgyNzcsImV4cCI6MjA2Mjc3NDI3N30.KktrFMFf6tgby1yVtePAJK7n5IFt6kz3CrpogCrp9DQ"
    static let publishableKey = "sb_publishable_liuWudtUV5qBGWL8DIvPqw_uShDP5H4"
}
