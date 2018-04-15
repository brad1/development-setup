require 'zip' # after gem install rubyzip

hash = Time.now.to_f.to_s.hash
hash = (hash*hash).to_s.slice(0,8)

zipfile = ''
contents = ''

require 'fileutils'
['C:/', '/'].each do |path|
  begin
    to_make = "#{path}tmp/#{hash}"
    contents = "#{to_make}/contents"
    FileUtils.mkdir_p("contents")
    zipfile = "#{to_make}/archive.zip" 
  rescue
  end
end

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(inputDir, outputFile)
    @inputDir = inputDir
    @outputFile = outputFile
  end
  # Zip the input directory.
  def write()
    entries = Dir.entries(@inputDir); entries.delete("."); entries.delete("..")
    io = Zip::File.open(@outputFile, Zip::File::CREATE);
    writeEntries(entries, "", io)
    io.close();
  end
  # A helper method to make the recursion work.
  private
  def writeEntries(entries, path, io)
    entries.each { |e|
      zipFilePath = path == "" ? e : File.join(path, e)
      diskFilePath = File.join(@inputDir, zipFilePath)
      puts "Deflating " + diskFilePath
      if File.directory?(diskFilePath)
        io.mkdir(zipFilePath)
        subdir =Dir.entries(diskFilePath); subdir.delete("."); subdir.delete("..")
        writeEntries(subdir, zipFilePath, io)
      else
        io.get_output_stream(zipFilePath) { |f| f.print(File.open(diskFilePath, "rb").read())}
      end
    }
  end
end

def unzip_file (file, destination)
    ::Zip::File.open(file) { |zip_file|
        zip_file.each { |f|
            f_path=File.join(destination, f.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            zip_file.extract(f, f_path) unless File.exist?(f_path)
        }
    }
end

ZipFileGenerator.new(contents, zipfile).write()
