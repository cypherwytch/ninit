import cligen
import shell


proc main(
    git = true,
    author = "",
    binary = true,
    library = false,
    license = "MIT",
    version = "",
    nimversion = "",
    description = "",
    package: string = ""
) =
    shell:
        nimble init ($package)
        expect: "Your name? [Anonymous]"
        send: $author
        expect: "Package type?"
        send: "\t"
        expect: "Initial version of package?"
        send: ($version)
        expect: "Package description?"
        send: ($description)
        expect: "Package License?"
        send: ($license)
        expect: "Lowest supported Nim version?"
        send: ($nimversion)


if isMainModule:
    dispatch main