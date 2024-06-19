import os, strformat, std/paths
import regex
import cligen

{.define(shellNoDebugOutput).}
{.define(shellNoDebugCommand).}
import shell


type
    PackageInfo = object
        git: bool
        binary: bool
        library: bool
        author: string
        license: string
        version: string
        nimversion: string
        description: string
        package: string



const defaultNimVersion = "2.0.0"
const srcDir = "src"
const testDir = "tests"

const fnameGitignore = ".gitignore"

const gitignoreTemplate = """
{pinfo.package}
"""

const binarySpecTemplate = """
installExt    = @["nim"]
bin           = @["{binary}"]
"""


const nimbleFileTemplate = """
# Package

version       = "{pinfo.version}"
author        = "{pinfo.author}"
description   = "{pinfo.description}"
license       = "{pinfo.license}"
srcDir        = "src"
{binarySpec}


# Dependencies

requires "nim >= {pinfo.nimversion}"
"""


const fnameTestConfig = "tests/config.nims"


const testConfig = """
switch("path", "$projectDir/../src")
"""


const fnameTest1 = "tests/test1.nim"


const testLibraryTemplate = """
# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import {pinfo.package}
test "can add":
  check add(5, 5) == 10
"""



const testHybridTemplate = """
# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import {pinfo.package}pkg/submodule
test "correct welcome":
  check getWelcomeMessage() == "Hello, World!"
"""



const submoduleTemplate = """
# This is just an example to get you started. Users of your library will
# import this file by writing ``import test/submodule``. Feel free to rename or
# remove this file altogether. You may create additional modules alongside
# this file as required.

type
  Submodule* = object
    name*: string

proc initSubmodule*(): Submodule =
  ## Initialises a new ``Submodule`` object.
  Submodule(name: "Anonymous")
"""


const libraryTemplate = """
# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.

proc add*(x, y: int): int =
  ## Adds two numbers together.
  return x + y
"""


const binaryTemplate = """
# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

when isMainModule:
  echo("Hello, World!")
"""


const hybridTemplate = """
# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import {pinfo.package}pkg/submodule

when isMainModule:
  echo(getWelcomeMessage())
"""


const hybridSubmoduleTemplate = """
# This is just an example to get you started. Users of your hybrid library will
# import this file by writing ``import qwobeiqwbieoqiweobeiobqweqbwioqbeowiqewbioqweioqweboipkg/submodule``. Feel free to rename or
# remove this file altogether. You may create additional modules alongside
# this file as required.

proc getWelcomeMessage*(): string = "Hello, World!"
"""


proc getNimVersion(): string =
    var versionFullText = ""
    shellAssign:
        versionFullText = nim --version
    var m: RegexMatch2
    if versionFullText.find(re2"(\d+\.\d+\.\d+)", m):
        result = versionFullText[m.boundaries]
    else:
        result = defaultNimVersion


proc packageName(package: string): string =
    if package == "":
        result = paths.getCurrentDir().lastPathPart().string
    else: result = package


proc mkdir(path: string) =
    discard existsOrCreateDir(path)


proc gitInit(pinfo: PackageInfo) =
    if pinfo.git:
        let gitignoreTxt = fmt(gitignoreTemplate)
        fnameGitignore.writeFile(gitignoreTxt)
        shell:
            git init


proc initializeHybrid(pinfo: PackageInfo) =
    let
        binary = pinfo.package
        binarySpec = fmt(binarySpecTemplate)
        hybridSubmoduleTxt = fmt(hybridSubmoduleTemplate)
        hybridTxt = fmt(hybridTemplate)
        nimbleFileTxt = fmt(nimbleFileTemplate)
        test1Txt = fmt(testHybridTemplate)
        submoduleDir = srcDir & "/" & pinfo.package & "pkg"
        fnameMain = "src/" & pinfo.package & ".nim"
        fnameSubmodule = submoduleDir & "/submodule.nim"
        fnameNimble = pinfo.package & ".nimble"
    mkdir srcDir
    mkdir testDir
    mkdir submoduleDir
    fnameMain.writeFile(hybridTxt)
    fnameSubmodule.writeFile(hybridSubmoduleTxt)
    fnameNimble.writeFile(nimbleFileTxt)
    fnameTest1.writeFile(test1Txt)
    fnameTestConfig.writeFile(testConfig)


proc initializeBinary(pinfo: PackageInfo) =
    let
        binary = pinfo.package
        binarySpec = fmt(binarySpecTemplate)
        binaryTxt = fmt(binaryTemplate)
        nimbleFileTxt = fmt(nimbleFileTemplate)
        fnameMain = "src/" & pinfo.package & ".nim"
        fnameNimble = pinfo.package & ".nimble"
    mkdir srcDir
    fnameMain.writeFile(binaryTxt)
    fnameNimble.writeFile(nimbleFileTxt)


proc initializeLibrary(pinfo: PackageInfo) =
    let
        binarySpec = ""
        libraryTxt = fmt(libraryTemplate)
        submoduleTemplateTxt = fmt(submoduleTemplate)
        test1Txt = fmt(testLibraryTemplate)
        nimbleFileTxt = fmt(nimbleFileTemplate)
        submoduleDir = "src/" & pinfo.package
        fnameMain = "src/" & pinfo.package & ".nim"
        fnameSubmodule = submoduleDir & "/submodule.nim"
        fnameNimble = pinfo.package & ".nimble"
    mkdir srcDir
    mkdir testDir
    mkdir submoduleDir
    fnameMain.writeFile(libraryTxt)
    fnameSubmodule.writeFile(submoduleTemplateTxt)
    fnameNimble.writeFile(nimbleFileTxt)
    fnameTest1.writeFile(test1Txt)
    fnameTestConfig.writeFile(testConfig)


template hybrid(pinfo: PackageInfo): bool = pinfo.binary == pinfo.library


proc initialize(pinfo: PackageInfo) =
    gitInit(pinfo)
    if pinfo.hybrid:
        pinfo.initializeHybrid()
    elif pinfo.binary:
        pinfo.initializeBinary()
    else:
        pinfo.initializeLibrary()


proc main(
    git = false,
    author = "Anonymous",
    binary = false,
    library = false,
    license = "MIT",
    version = "0.1.0",
    nimversion = "",
    description = "A new awesome nimble package",
    package: string = ""
) =
    if package != "":
        if package.dirExists:
            raise newException(OSError, "Directory already exists")
        createDir(package)
        setCurrentDir(package)
    let nVersion = if nimversion.len == 0: getNimVersion() else: nimversion
    let pinfo = PackageInfo(
        git: git,
        binary: binary,
        library: library,
        author: author,
        license: license,
        version: version,
        nimversion: nVersion,
        description: description,
        package: packageName(package)
    )
    pinfo.initialize()


if isMainModule:
    dispatch main
