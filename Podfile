# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

abstract_target "2048_shared" do

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # add pods for desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'

  target 'play2048'
  target 'play2048_dev'

  
end

target 'play2048Tests' do
    inherit! :search_paths
end
