require File.join(File.dirname(__FILE__), 'base.rb')

#TODO add exception for 
#cannot load such file -- /Users/tim/dev/gga/devops-webapp/lib/workers/.base.rb.swp (LoadError)
Dir.new(File.dirname(__FILE__)).each do |file|
  next if ['.', '..', 'all.rb', 'base.rb'].include?(file)
  require File.join(File.dirname(__FILE__), file)
end

