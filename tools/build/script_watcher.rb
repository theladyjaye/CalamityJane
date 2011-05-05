require "rubygems"
require "fssm"

# if you don't have fssm then run:
# "gem install fssm" or "sudo gem install fssm"

def watch_js(path)  
  FSSM.monitor(path, '**/*.js') do
    update { |path, file| update_js(path, file) }
    delete { |path, file| delete_js(path, file) }
    create { |path, file| create_js(path, file) }
  end
end

def update_js(path, file)
  puts "Update in #{path} to #{file}"
  compile_js("../../builds/dev")
end

def delete_js(path, file)
  puts "Delete in #{path} to #{file}"
  compile_js("../../builds/dev")
end

def create_js(path, file)
  puts "Create in #{path} to #{file}"
  compile_js("../../builds/dev")
end