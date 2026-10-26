#!/usr/bin/env python3
"""Regenerate the catalog Xcode project from its sources and local kit dependencies."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[1]
EXAMPLE = ROOT / "Examples/CustomKitCatalog"
PROJECT = EXAMPLE / "CustomKitCatalog.xcodeproj"
objects = {}


def ref(name):
    return hashlib.sha1(name.encode()).hexdigest()[:24].upper()


def add(name, kind, fields):
    identifier = ref(name)
    objects[identifier] = f"isa = {kind}; {fields}"
    return identifier


def quoted(value):
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"') + '"'


def sequence(values):
    return "(" + ", ".join(values) + ("," if values else "") + ")"


def file(path, filetype):
    relative = path.relative_to(EXAMPLE).as_posix()
    return add(relative, "PBXFileReference", f"lastKnownFileType = {filetype}; path = {quoted(relative)}; sourceTree = SOURCE_ROOT;")


def phase(name, kind, paths, filetype):
    files = []
    for path in paths:
        item = file(path, filetype(path) if callable(filetype) else filetype)
        files.append(add(f"build-{path}", "PBXBuildFile", f"fileRef = {item};"))
    return add(name, kind, f"buildActionMask = 2147483647; files = {sequence(files)}; runOnlyForDeploymentPostprocessing = 0;")


def config_list(name, settings):
    configs = []
    for mode in ["Debug", "Release"]:
        values = dict(settings)
        values.update({"SWIFT_OPTIMIZATION_LEVEL": quoted("-Onone" if mode == "Debug" else "-O")})
        if mode == "Debug":
            values["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = quoted("DEBUG $(inherited)")
            values["ONLY_ACTIVE_ARCH"] = "YES"
        text = " ".join(f"{key} = {value};" for key, value in values.items())
        configs.append(add(f"{name}-{mode}", "XCBuildConfiguration", f"buildSettings = {{{text}}}; name = {mode};"))
    return add(f"{name}-configs", "XCConfigurationList", f"buildConfigurations = {sequence(configs)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;")


PROJECT.mkdir(parents=True, exist_ok=True)
source_paths = sorted((EXAMPLE / "Sources").rglob("*.swift")) + sorted((EXAMPLE / "Integrations").rglob("*.swift"))
test_paths = sorted((EXAMPLE / "UITests").rglob("*.swift"))
resource_types = {
    ".mov": "video.quicktime",
    ".xcassets": "folder.assetcatalog",
    ".xcprivacy": "text.xml",
}
resources = sorted(path for path in (EXAMPLE / "Resources").iterdir() if path.suffix in resource_types)
app_sources = phase("app-sources", "PBXSourcesBuildPhase", source_paths, "sourcecode.swift")
app_resources = phase("app-resources", "PBXResourcesBuildPhase", resources, lambda path: resource_types[path.suffix])
test_sources = phase("test-sources", "PBXSourcesBuildPhase", test_paths, "sourcecode.swift")
test_frameworks = phase("test-frameworks", "PBXFrameworksBuildPhase", [], "wrapper.framework")
package_refs = []
products = []
frameworks = []
packages = {
    "CustomKit": ("../..", ["CustomKit", "CustomKitCatalog"]),
    "KaizoshaPlayerKit": ("../../../KaizoshaPlayerKit", ["KaizoshaPlayer", "KaizoshaPlayerUI"]),
    "KaizoshaCaptionKit": ("../../../KaizoshaCaptionKit", ["KaizoshaCaptionCore"]),
    "SekaiKit": ("../../../Sekai", ["SekaiKit"]),
}
for name, (path, product_names) in packages.items():
    package = add(f"package-{name}", "XCLocalSwiftPackageReference", f"relativePath = {quoted(path)};")
    package_refs.append(package)
    for product_name in product_names:
        product = add(f"product-{product_name}", "XCSwiftPackageProductDependency", f"package = {package}; productName = {product_name};")
        products.append(product)
        frameworks.append(add(f"framework-{product_name}", "PBXBuildFile", f"productRef = {product};"))
app_frameworks = add("app-frameworks", "PBXFrameworksBuildPhase", f"buildActionMask = 2147483647; files = {sequence(frameworks)}; runOnlyForDeploymentPostprocessing = 0;")
app_product = add("app-product", "PBXFileReference", 'explicitFileType = wrapper.application; includeInIndex = 0; path = CustomKitCatalog.app; sourceTree = BUILT_PRODUCTS_DIR;')
test_product = add("test-product", "PBXFileReference", 'explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = CustomKitCatalogUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
product_group = add("products", "PBXGroup", f"children = {sequence([app_product, test_product])}; name = Products; sourceTree = \"<group>\";")
all_files = [ref(p.relative_to(EXAMPLE).as_posix()) for p in source_paths + resources + test_paths]
main_group = add("main-group", "PBXGroup", f"children = {sequence(all_files + [product_group])}; sourceTree = \"<group>\";")
common = {
    "IPHONEOS_DEPLOYMENT_TARGET": "27.0",
    "SWIFT_VERSION": "6.0",
    "SDKROOT": "iphoneos",
    "SUPPORTED_PLATFORMS": quoted("iphoneos iphonesimulator"),
    "TARGETED_DEVICE_FAMILY": quoted("1,2"),
    "GENERATE_INFOPLIST_FILE": "YES",
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "564DV375U4",
    "PRODUCT_NAME": quoted("$(TARGET_NAME)"),
}
app_settings = dict(
    common,
    PRODUCT_NAME="CustomKitCatalog",
    PRODUCT_MODULE_NAME="CustomKitCatalogApp",
    PRODUCT_BUNDLE_IDENTIFIER="org.kaizosha.CustomKit",
    INFOPLIST_KEY_CFBundleDisplayName=quoted("CustomKit"),
    INFOPLIST_KEY_UILaunchScreen_Generation="YES",
    INFOPLIST_KEY_UIApplicationSceneManifest_Generation="YES",
    INFOPLIST_KEY_ITSAppUsesNonExemptEncryption="NO",
    INFOPLIST_KEY_LSApplicationCategoryType=quoted("public.app-category.developer-tools"),
    CURRENT_PROJECT_VERSION="2",
    MARKETING_VERSION="1.0",
    ENABLE_PREVIEWS="YES",
    SKIP_INSTALL="NO",
    ASSETCATALOG_COMPILER_APPICON_NAME="AppIcon",
    INFOPLIST_KEY_UISupportedInterfaceOrientations=quoted("UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"),
)
app_configs = config_list("app", app_settings)
test_configs = config_list("tests", dict(common, PRODUCT_BUNDLE_IDENTIFIER="org.kaizosha.CustomKitCatalogUITests", TEST_TARGET_NAME="CustomKitCatalogApp"))
app_target = add("app-target", "PBXNativeTarget", f"buildConfigurationList = {app_configs}; buildPhases = {sequence([app_sources, app_frameworks, app_resources])}; buildRules = (); dependencies = (); name = CustomKitCatalogApp; packageProductDependencies = {sequence(products)}; productName = CustomKitCatalog; productReference = {app_product}; productType = \"com.apple.product-type.application\";")
proxy = add("test-proxy", "PBXContainerItemProxy", f"containerPortal = {ref('project')}; proxyType = 1; remoteGlobalIDString = {app_target}; remoteInfo = CustomKitCatalogApp;")
dependency = add("test-dependency", "PBXTargetDependency", f"target = {app_target}; targetProxy = {proxy};")
test_target = add("test-target", "PBXNativeTarget", f"buildConfigurationList = {test_configs}; buildPhases = {sequence([test_sources, test_frameworks])}; buildRules = (); dependencies = {sequence([dependency])}; name = CustomKitCatalogUITests; productName = CustomKitCatalogUITests; productReference = {test_product}; productType = \"com.apple.product-type.bundle.ui-testing\";")
project_configs = config_list("project", {"CLANG_ENABLE_MODULES": "YES", "SWIFT_STRICT_CONCURRENCY": "complete"})
project = add("project", "PBXProject", f"attributes = {{BuildIndependentTargetsInParallel = YES; LastUpgradeCheck = 2700; TargetAttributes = {{{test_target} = {{TestTargetID = {app_target};}};}};}}; buildConfigurationList = {project_configs}; compatibilityVersion = \"Xcode 16.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base); mainGroup = {main_group}; packageReferences = {sequence(package_refs)}; productRefGroup = {product_group}; projectDirPath = \"\"; projectRoot = \"\"; targets = {sequence([app_target, test_target])};")
body = "\n".join(f"\t\t{key} = {{{value}}};" for key, value in objects.items())
(PROJECT / "project.pbxproj").write_text(f"// !$*UTF8*$!\n{{\n\tarchiveVersion = 1;\n\tclasses = {{}};\n\tobjectVersion = 77;\n\tobjects = {{\n{body}\n\t}};\n\trootObject = {project};\n}}\n")
scheme_dir = PROJECT / "xcshareddata/xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)
app_reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{app_target}" BuildableName="CustomKitCatalog.app" BlueprintName="CustomKitCatalogApp" ReferencedContainer="container:CustomKitCatalog.xcodeproj"/>'
test_reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{test_target}" BuildableName="CustomKitCatalogUITests.xctest" BlueprintName="CustomKitCatalogUITests" ReferencedContainer="container:CustomKitCatalog.xcodeproj"/>'
(scheme_dir / "CustomKitCatalog.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.3">
  <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app_reference}</BuildActionEntry></BuildActionEntries></BuildAction>
  <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{test_reference}</TestableReference></Testables></TestAction>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app_reference}</BuildableProductRunnable></LaunchAction>
  <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app_reference}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')
print(PROJECT)
