require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  #
  # We need to be sure that both of these methods are called on sync
  # #
  test '#sync_packages should call #load_packages and #fill_out_packages' do
    allow(Package).to receive(:load_packages!).with(nil).and_return(nil)
    allow(Package).to receive(:fill_out_packages!).and_return(nil)
    expect(Package).to receive(:load_packages!)
    expect(Package).to receive(:fill_out_packages!)
    Package.sync_packages!
  end

  test '#load_packages should create a new package with data returned by CRAN' do
    allow(CranParser).to receive(:get_package_list).with(nil).and_return(
        [{
             'Package': 'test_package',
             'Version': '1.2.3'
         }.with_indifferent_access]
    )
    assert_difference('Package.count', 1) do
      Package.load_packages!
    end
  end

  test '#fill_out should correctly set the author and maintainer of the package with decription data' do
    allow_any_instance_of(CranParser).to receive(:package_data).and_return(
        {
            'Author': 'Test authors list',
            'Maintainer': 'test user <test@test.de>'
        }.with_indifferent_access
    )
    package = packages(:correct_package)
    package.fill_out!
    assert_equal package.authors, 'Test authors list'
    assert_equal package.maintainer_email, 'test@test.de'
    assert_equal package.maintainer_name, 'test user'
  end
end
