require 'digest/sha1'

=begin

Locate script class
All paths are now absolute

@todo support multiple files, only compiling one file
 
@param root_path        path to deploy files
@param compiler_path    path to location of compiler
=end
class Locate_script
  def initialize(root_path, compiler_path)
    @root = root_path
    @compiler_path = compiler_path
    @compiled_out = "/resources/js/%compiled_file_name%.min.js"
    @scripts = {}
  end

  def compile
    compiled_js_file_name = find_files()
    
    command = "java -jar #{@compiler_path}/compiler.jar "

    @scripts.each do | key, value |
      command = command + "--js #{value} "
    end

    command = command + "--js_output_file " + @root + compiled_js_file_name
    
    # run shell command    
    `#{command}`
  end

  def find_files
    compiled_js_file_name = ""
    Dir.glob("#{@root}/*.{php,html}") do |file|
      File.open(file, "r") do |infile|
        newFile = ""
        while (line = infile.gets)
          candidate = line.strip()

          if candidate.match(/^<script[^>]+><\/script>$/)
            src = line.match(/src="([^"]+)"/)[1]
            slash = /^\// =~  src ? '' : '/' # <-- what is going on here? removing initial slash?
          
            # remove starting slash if exists
            # %r is regex
            src = src.sub!(%r{^\/}, "")             
            
            # hash off the contents of the entire file not the filename
            # better way to ensure no duplicates
            key = Digest::SHA1.hexdigest(File.read("#{@root}/#{src}"))
        
            if !@scripts.has_key?(key)
              @scripts[key] = "#{@root}/#{src}" #@root + slash + src
            end
          else
            newFile = newFile + line
          end
        end
    
        # create compiled js file name for current file
        compiled_js_file_name = compiled_js_file(file)
        
        parts = newFile.split("</body>")
        parts[0] = parts[0] + "\t<script src=\"#{compiled_js_file_name}\"></script>\n"
        newFile =  parts.join("</body>\n")
        
        # by this point newFile represents the contents of the target file that should be written      
        # overwrite file with compiled script name
        File.open(file, 'w') {|f| f.write(newFile)}
      end
    end
    
    return compiled_js_file_name
  end
  
  def compiled_js_file(file)
    basename_with_rand = File.basename(file, '.*') + "-" + rand_num
    return @compiled_out.gsub("%compiled_file_name%", basename_with_rand)
  end
    
  # just need a random number to prevent conflicts in compiled js files
  # this may be too much
  # http://www.themomorohoax.com/2009/09/22/securerandom-stop-writing-your-own-random-number-and-string-generators  
  def rand_num
    return Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
  end
end