require 'test_helper'

class CranParserTest < ActiveSupport::TestCase

  class GetPackageTests < ActiveSupport::TestCase
    #
    # Make sure all the data parsed from CRAN has a 'Package' attribute,
    # otherwise there is nothing to be done with it
    # #
    test 'can get data from CRAN server' do
      limit = 50
      data = CranParser.get_package_list(limit)
      assert data.count == limit && data.select {
          |package_data| package_data['Package'].nil?
      }.count == 0
    end
  end

  class PackageDataTests < ActiveSupport::TestCase
    #
    # Correct packages should have data returned
    # #
    test 'returns data for the correct package' do
      package = packages(:correct_package)
      cran = CranParser.new(package)
      assert cran.package_data.present? && cran.package_data['Author'].present?
    end

    #
    # Corrupted names and versions should retrieve no data
    # #
    test 'returns nothing if package is not there' do
      package = packages(:incorrect_package)
      cran = CranParser.new(package)
      assert cran.package_data.nil?
    end
  end
end
