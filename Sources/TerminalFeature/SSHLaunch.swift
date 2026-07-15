import Foundation

/// The SSH launch payload Terminal accepts via `host.apps.takePendingLaunch()`.
/// Opaque JSON on the wire; `kind` must be "ssh".
struct SSHLaunch: Decodable, Equatable {
    let host: String
    let port: Int
    let username: String
    let identityFile: String?

    private enum CodingKeys: String, CodingKey { case kind, host, port, username, identityFile }

    init?(json: String?) {
        guard let json, let data = json.data(using: .utf8) else { return nil }
        guard let c = try? JSONDecoder().decode(SSHLaunch.self, from: data) else { return nil }
        self = c
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard try c.decode(String.self, forKey: .kind) == "ssh" else {
            throw DecodingError.dataCorruptedError(forKey: .kind, in: c, debugDescription: "not ssh")
        }
        host = try c.decode(String.self, forKey: .host)
        port = try c.decode(Int.self, forKey: .port)
        username = try c.decode(String.self, forKey: .username)
        identityFile = try c.decodeIfPresent(String.self, forKey: .identityFile)
    }
}

/// Builds the `/usr/bin/ssh` invocation for a launch.
enum SSHInvocation {
    static let executable = "/usr/bin/ssh"
    static func argv(_ l: SSHLaunch) -> [String] {
        var a: [String] = []
        if let f = l.identityFile, !f.isEmpty { a += ["-i", f] }
        if l.port != 22 { a += ["-p", String(l.port)] }
        a.append(l.username.isEmpty ? l.host : "\(l.username)@\(l.host)")
        return a
    }
}
