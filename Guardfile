# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript', :input => 'src', :output => 'public', :run_at_start => true

#guard 'sass', :input => 'src', :output => 'public', :run_at_start => true

guard 'haml', :input => 'src', :output => 'public', :run_at_start => true do
  watch %r{^src/.+(\.haml)$}
end

guard 'compass' do
  watch %r{^src/.+(\.s[ac]ss)$}
end
