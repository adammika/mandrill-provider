import Vapor

public final class Provider: Vapor.Provider {
    public static let repositoryName = "mandrill-provider"

    public init(config: Config) throws { }

    public func boot(_ config: Config) throws {
        config.addConfigurable(mail: Mandrill.init, name: "mandrill")
    }

    public func boot(_ drop: Droplet) throws { }
    public func beforeRun(_ drop: Droplet) {}
}