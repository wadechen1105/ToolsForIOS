# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!
def inherit_pods
    # Pods for Tools
    pod 'SSZipArchive'
    pod 'SwiftyJSON'
    pod 'FMDB'
    pod 'FMDBMigrationManager'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'MXLCalendarManager'
end

target 'Tools' do
    inherit_pods
end

target 'Tools-dev' do
    inherit_pods
end

target 'ToolsDevTests' do
    inherit_pods
end

target 'ToolsUITests' do
    inherit! :search_paths
    # Pods for testing
end
