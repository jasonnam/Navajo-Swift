
Pod::Spec.new do |s|

  s.name             = "Navajo-Swift"
  s.version          = "0.0.2"
  s.summary          = "Password Validator & Strength Evaluator"

  s.description      = <<-DESC
                       Evaluating Password Strength
                       Validating Password

                       Available Validation Rules
                       -Allowed Characters
                       -Required Characters (custom, lowercase, uppercase, decimal, symbol)
                       -Non-Dictionary Word
                       -Minimum / Maximum Length
                       -Predicate Match
                       -Regular Expression Match
                       -Block Evaluation

                       Localization
                       DESC

  s.homepage         = "https://github.com/jasonnam/Navajo-Swift"

  s.author           = { "Jason Nam" => "contact@jasonnam.com" }
  s.social_media_url = "http://www.jasonnam.com"

  s.license          = { :type => "MIT", :file => "LICENSE" }

  s.ios.deployment_target = '8.0'

  s.source                = { :git    => "https://github.com/jasonnam/Navajo-Swift.git",
                              :commit => "3e6e6773dddb9511aa61a632fe44d6318368acd3",
                              :tag    => "0.0.2" }

  s.source_files = "Navajo.swift"
  s.requires_arc = true

end
