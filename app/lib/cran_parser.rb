require 'open-uri'
require 'dcf'
require 'fileutils'
require 'rubygems/package'
require 'zlib'
require './app/lib/core_ext/string'

#
# Helper library used to connect to 'CRAN' server and get infos about 'R' packages
# #
class CranParser
  CRAN_PACKAGES_URL = 'http://cran.r-project.org/src/contrib'
  attr_accessor :package

  #
  # Returns the entire list of all the data on the CRAN server as hashes
  # 'limit' param determines the amount of packages to be returned
  # 'offset' determines how many packages should be skipped
  # #
  def self.get_package_list(limit = nil, offset = 0)
    data = URI.parse(CRAN_PACKAGES_URL + '/PACKAGES').read
    if limit.present?
      data = data.split("\n\n")[offset..offset + limit - 1].join("\n\n")
    end
    Dcf.parse(data).collect(&:with_indifferent_access)
  end

  def initialize(package)
    @package = package
  end

  #
  # Returns data hash for the initialized object if description file present
  # and url path correct. Sometimes package file can not be reached because
  # name and version inside the 'PACKAGES' file is outdated.
  #
  # Additionally, updates the encoding of returned hash, otherwise the importer
  # will cause issues with ruby
  # #
  def package_data
    source = open(file_url)
    gz = Zlib::GzipReader.new(source)
    Gem::Package::TarReader.new(gz) do |tar|
      tar.each do |entry|
        if entry.full_name == @package.package_name + '/DESCRIPTION'
          data = Dcf.parse(entry.read).first
          data.each do |key, value|
            data[key] = value.to_s.to_utf8
          end
          return data.with_indifferent_access
        end
      end
    end
  rescue OpenURI::HTTPError
    warn "could not parse package #{@package.package_name} version #{@package.version}, url likely corrupt"
    return nil
  end

  #
  # Address of the downloadable file from the CRAN server
  # #
  def file_url
    return "#{CRAN_PACKAGES_URL}/#{@package.package_name}_#{@package.version}.tar.gz"
  end
end
