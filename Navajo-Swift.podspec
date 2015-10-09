
Pod::Spec.new do |s|

  s.name             = "Navajo-Swift"
  s.version          = "0.0.3"
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
                              :commit => "29a0e4dd4e3a533239b1f037183d4da0b579ec77",
                              :tag    => "0.0.3" }

  s.source_files = "Source/*.{swift}"
  s.requires_arc = true

end
