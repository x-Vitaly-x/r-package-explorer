class CreatePackages < ActiveRecord::Migration[5.2]
  def change
    create_table :packages do |t|
      t.string :package_name
      t.string :version
      t.string :publication_date
      t.text :title
      t.text :description
      t.text :authors
      t.string :maintainer_name
      t.string :maintainer_email
      t.timestamps
    end
  end
end
