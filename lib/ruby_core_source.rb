
require 'rbconfig'
require 'tempfile'
require 'tmpdir'

require File.join(File.dirname(__FILE__), 'contrib', 'uri_ext')
require 'archive/tar/minitar'
require 'zlib'
require 'fileutils'

module Ruby_core_source

def get_ruby_core_source
  if RUBY_PATCHLEVEL < 0
    patch_str = "preview1" # TODO
  else
    patch_str = "p" + RUBY_PATCHLEVEL.to_s
  end

  ruby_dir = "ruby-" + RUBY_VERSION.to_s + "-" + patch_str
  dest_dir = Config::CONFIG["rubyhdrdir"] + "/" + ruby_dir
  uri_path = "http://ftp.ruby-lang.org/pub/ruby/1.9/" + ruby_dir + ".tar.gz"

  Tempfile.open("ruby-src") { |temp|

    temp.binmode
    uri = URI.parse(uri_path)
    uri.download(temp)

    tgz = Zlib::GzipReader.new(File.open(temp, "rb"))

    FileUtils.mkdir_p(dest_dir)
    Dir.mktmpdir { |dir|
      inc_dir = dir + "/" + ruby_dir + "/*.inc"
      hdr_dir = dir + "/" + ruby_dir + "/*.h"
      Archive::Tar::Minitar.unpack(tgz, dir)
      FileUtils.cp(Dir.glob([ inc_dir, hdr_dir ]), dest_dir)
    }
  }

  dest_dir
end
module_function :get_ruby_core_source

end
