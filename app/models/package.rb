require 'mail'

class Package < ApplicationRecord
  validates_uniqueness_of :package_name, scope: :version
  validates_presence_of :package_name, :version
  #
  # Method to synchronize packages from CRAN library
  # limit determines the amount of packages to be retrieved from CRAN server
  # #
  def self.sync_packages!(limit = nil)
    self.load_packages!(limit)
    self.fill_out_packages!
  end

  #
  # Gets the package list from CRAN library and creates the Package object
  # #
  def self.load_packages!(limit = nil)
    CranParser.get_package_list(limit).each do |data|
      Package.find_or_create_by!(
          package_name: data['Package'],
          version: data['Version'])
    end
  end

  #
  # Goes through all packages and fills out their data from 'Description' file
  # #
  def self.fill_out_packages!
    Package.where(authors: nil).each do |pack|
      pack.fill_out!
    end
  end

  #
  # Downloads the 'Description' file from the server and fills out stored data for the object
  # Complications can arise from encoding issues in 'Author' field
  # #
  def fill_out!
    CranParser.new(self).package_data.tap do |data|
      if data.present?
        p data
        maintainer_mail_data = Mail::Address.new(data['Maintainer'])
        self.update_attributes!(
            authors: data['Author'],
            publication_date: data['Date'],
            title: data['Title'],
            description: data['Description'],
            maintainer_name: maintainer_mail_data.display_name,
            maintainer_email: maintainer_mail_data.address)
      end
    end
  end
end
