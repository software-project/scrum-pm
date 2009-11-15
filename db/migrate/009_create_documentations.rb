class CreateDocumentations < ActiveRecord::Migration
  def self.up
    create_table :documentations do |t|
      t.column :version, :integer
      t.column :path, :string
    end
  end

  def self.down
    drop_table :documentations
  end
end
