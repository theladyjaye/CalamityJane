require 'digest/sha1'
root = "../../DEV_Deploy"
compiled_out = "/resources/js/compiled.js"
scripts = {}

Dir.glob(root + "/*.php") do |file|
  File.open(file, "r") do |infile|
    newFile = ""
    while (line = infile.gets)
      candidate = line.strip()
      
      if candidate.match(/^<script[^>]+><\/script>$/)
        src = line.match(/src="([^"]+)"/)[1]
        slash = /^\// =~  src ? '' : '/'
        
        # hash off the contents of the entire file not the filename
        # better way to ensure no duplicates
        key = Digest::SHA1.hexdigest(File.read(root + slash + src))
        
        if !scripts.has_key?(key)
          scripts[key] = root + slash + src
        end
      else
        newFile = newFile + line
      end
    end
    
    parts = newFile.split("</body>")
    parts[0] = parts[0] + "\t<script src=\"#{compiled_out}\"></script>\n"
    newFile =  parts.join("</body>\n")
    # by this point newFile represents the contents of the target file that should be written
    puts "\n\nnewFile Path: #{file}\n\n"
  
  end
end

command = "java -jar compiler.jar "

scripts.each do | key, value |
  command = command + "--js #{value} "
end

command = command + "--js_output_file " + root + compiled_out
puts "Compile Command: \n\n#{command}\n"
