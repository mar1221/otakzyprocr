# This migration comes from refinery_elections (originally 1)
class CreateElectionsElections < ActiveRecord::Migration

  def up
    create_table :refinery_elections do |t|
      t.string :title, :null => false
      t.integer :election_type_id, :null => false
      t.datetime :held, :null => false
      t.text :notes
      t.integer :position

      t.timestamps
    end

    add_index :refinery_elections, [:election_type_id, :held], :unique => true

  end

  def down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({:name => "refinerycms-elections"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/elections/elections"})
    end

    drop_table :refinery_elections

  end

end