import Foundation
import Cocoa

class UpdateChecker {
    static let shared = UpdateChecker()
    
    private let githubRepo = "D3FVLT/MagicTouch"
    private let releasesURL: URL
    
    private init() {
        releasesURL = URL(string: "https://api.github.com/repos/\(githubRepo)/releases/latest")!
    }
    
    struct GitHubRelease: Codable {
        let tagName: String
        let htmlUrl: String
        let name: String
        let body: String?
        
        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlUrl = "html_url"
            case name
            case body
        }
    }
    
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
    
    func checkForUpdates(silent: Bool = false, completion: ((Bool, GitHubRelease?) -> Void)? = nil) {
        var request = URLRequest(url: releasesURL)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    if !silent {
                        self.showError("Failed to check for updates: \(error.localizedDescription)")
                    }
                    completion?(false, nil)
                    return
                }
                
                guard let data = data else {
                    if !silent {
                        self.showError("No data received from GitHub")
                    }
                    completion?(false, nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                    if !silent {
                        self.showUpToDate()
                    }
                    completion?(false, nil)
                    return
                }
                
                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                    let latestVersion = release.tagName.replacingOccurrences(of: "v", with: "")
                    
                    if self.isVersion(latestVersion, newerThan: self.currentVersion) {
                        self.showUpdateAvailable(release: release, latestVersion: latestVersion)
                        completion?(true, release)
                    } else {
                        if !silent {
                            self.showUpToDate()
                        }
                        completion?(false, release)
                    }
                } catch {
                    if !silent {
                        self.showError("Failed to parse update info: \(error.localizedDescription)")
                    }
                    completion?(false, nil)
                }
            }
        }.resume()
    }
    
    private func isVersion(_ new: String, newerThan current: String) -> Bool {
        let newComponents = new.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(newComponents.count, currentComponents.count)
        
        for i in 0..<maxLength {
            let newPart = i < newComponents.count ? newComponents[i] : 0
            let currentPart = i < currentComponents.count ? currentComponents[i] : 0
            
            if newPart > currentPart {
                return true
            } else if newPart < currentPart {
                return false
            }
        }
        
        return false
    }
    
    private func showUpdateAvailable(release: GitHubRelease, latestVersion: String) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "A new version of MagicTouch is available!\n\nCurrent: \(currentVersion)\nLatest: \(latestVersion)\n\n\(release.name)"
        if let body = release.body, !body.isEmpty {
            alert.informativeText += "\n\n\(body)"
        }
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: release.htmlUrl) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func showUpToDate() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "MagicTouch \(currentVersion) is the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Update Check Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

